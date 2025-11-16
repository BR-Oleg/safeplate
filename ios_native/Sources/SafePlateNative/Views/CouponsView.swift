import SwiftUI

struct CouponsView: View {
    @EnvironmentObject var appState: AppState

    enum Tab {
        case my
        case redeem
    }

    enum StatusFilter: String, CaseIterable {
        case active
        case expired
        case all
    }

    private let couponsRepository: CouponsRepositoryProtocol = CouponsRepository()

    @State private var selectedTab: Tab = .my
    @State private var myCoupons: [Coupon] = []
    @State private var availableCoupons: [AvailableCoupon] = []
    @State private var statusFilter: StatusFilter = .active
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var filteredMyCoupons: [Coupon] {
        switch statusFilter {
        case .active:
            return myCoupons.filter { $0.status == .active }
        case .expired:
            return myCoupons.filter { $0.status == .expired || $0.status == .used }
        case .all:
            return myCoupons
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                pointsHeader
                tabPicker

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                }

                Group {
                    if selectedTab == .my {
                        myCouponsContent
                    } else {
                        redeemContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .navigationTitle(appState.localized("nav_coupons"))
            .onAppear {
                loadData()
            }
        }
    }

    private var pointsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seus pontos")
                .font(.headline)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(appState.points)")
                    .font(.system(size: 32, weight: .bold))
                Text("pts")
                    .foregroundColor(.secondary)
            }
            Text("Acumule pontos usando recursos seguros e troque por benefícios.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            Text("Meus cupons").tag(Tab.my)
            Text("Resgatar").tag(Tab.redeem)
        }
        .pickerStyle(.segmented)
    }

    private var myCouponsContent: some View {
        Group {
            if filteredMyCoupons.isEmpty {
                VStack(spacing: 8) {
                    Text("Você ainda não possui cupons.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 8) {
                    Picker("", selection: $statusFilter) {
                        Text("Ativos").tag(StatusFilter.active)
                        Text("Expirados").tag(StatusFilter.expired)
                        Text("Todos").tag(StatusFilter.all)
                    }
                    .pickerStyle(.segmented)

                    List {
                        ForEach(filteredMyCoupons) { coupon in
                            CouponRow(coupon: coupon, canRedeem: false, onRedeem: {})
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }

    private var redeemContent: some View {
        Group {
            if availableCoupons.isEmpty {
                VStack(spacing: 8) {
                    Text("Nenhum cupom disponível para resgate.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(availableCoupons) { coupon in
                        AvailableCouponRow(
                            coupon: coupon,
                            canRedeem: appState.points >= coupon.pointsCost
                        ) {
                            redeem(coupon)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func loadData() {
        guard let userId = appState.userId else { return }
        isLoading = true
        errorMessage = nil

        let group = DispatchGroup()
        var userCouponsResult: Result<[Coupon], Error>?
        var availableResult: Result<[AvailableCoupon], Error>?

        group.enter()
        couponsRepository.fetchUserCoupons(userId: userId) { result in
            userCouponsResult = result
            group.leave()
        }

        group.enter()
        couponsRepository.fetchAvailableCoupons { result in
            availableResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            isLoading = false
            if let userCouponsResult = userCouponsResult {
                switch userCouponsResult {
                case .success(let coupons):
                    myCoupons = coupons
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            if let availableResult = availableResult {
                switch availableResult {
                case .success(let coupons):
                    availableCoupons = coupons
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func redeem(_ available: AvailableCoupon) {
        guard let userId = appState.userId else {
            errorMessage = "Você precisa estar autenticado para resgatar cupons."
            return
        }
        isLoading = true
        errorMessage = nil

        couponsRepository.redeemCoupon(availableCouponId: available.id, userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let coupon):
                    appState.setPoints(appState.points - coupon.pointsCost)
                    myCoupons.insert(coupon, at: 0)
                    if let index = availableCoupons.firstIndex(where: { $0.id == available.id }) {
                        availableCoupons.remove(at: index)
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CouponRow: View {
    let coupon: Coupon
    let canRedeem: Bool
    let onRedeem: () -> Void

    private var statusText: String {
        switch coupon.status {
        case .active:
            return "Ativo"
        case .used:
            return "Usado"
        case .expired:
            return "Expirado"
        }
    }

    private var statusColor: Color {
        switch coupon.status {
        case .active:
            return .green
        case .used:
            return .blue
        case .expired:
            return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(coupon.title)
                    .font(.headline)
                Spacer()
                Text("\(coupon.pointsCost) pts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(coupon.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(statusText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)

                Spacer()

                if canRedeem {
                    Button("Resgatar", action: onRedeem)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AvailableCouponRow: View {
    let coupon: AvailableCoupon
    let canRedeem: Bool
    let onRedeem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(coupon.title)
                    .font(.headline)
                Spacer()
                Text("\(coupon.pointsCost) pts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(coupon.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(String(format: "%.0f%% de desconto", coupon.discount))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)

                Spacer()

                Button(action: onRedeem) {
                    Text(canRedeem ? "Resgatar" : "Pontos insuficientes")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(canRedeem ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                        .foregroundColor(canRedeem ? .green : .secondary)
                        .cornerRadius(12)
                }
                .disabled(!canRedeem)
            }
        }
        .padding(.vertical, 4)
    }
}
