import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/establishment_provider.dart';
import '../services/firebase_service.dart';
import '../services/cep_service.dart';
import '../services/geocoding_service.dart';
import '../models/establishment.dart';
import '../models/user.dart';

class BusinessRegisterEstablishmentScreen extends StatefulWidget {
  const BusinessRegisterEstablishmentScreen({super.key});

  @override
  State<BusinessRegisterEstablishmentScreen> createState() => _BusinessRegisterEstablishmentScreenState();
}

class _BusinessRegisterEstablishmentScreenState extends State<BusinessRegisterEstablishmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Set<DietaryFilter> _selectedDietaryOptions = {};
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  Set<int> _selectedDays = {}; // Dias da semana selecionados (0=domingo, 1=segunda, ..., 6=sábado)
  double? _latitude;
  double? _longitude;
  bool _isLoadingCep = false;
  bool _isLoadingGeocoding = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _cepController.dispose();
    _addressNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _searchCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty || cep.replaceAll(RegExp(r'[^0-9]'), '').length != 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, informe um CEP válido (8 dígitos)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    setState(() => _isLoadingCep = true);
    
    try {
      final addressData = await CepService.getAddressByCep(cep);
      
      if (addressData != null) {
        // Atualizar endereço com número se fornecido
        final number = _addressNumberController.text.trim();
        final formattedAddress = CepService.formatAddress(addressData, number.isNotEmpty ? number : null);
        
        setState(() {
          _addressController.text = formattedAddress;
        });
        
        // Fazer geocoding do endereço para obter lat/long
        setState(() => _isLoadingGeocoding = true);
        final coordinates = await GeocodingService.getCoordinatesFromAddress(formattedAddress);
        
        if (coordinates != null) {
          setState(() {
            _latitude = coordinates['latitude'];
            _longitude = coordinates['longitude'];
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Endereço encontrado e coordenadas obtidas! ✅'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Endereço encontrado, mas não foi possível obter coordenadas. Você pode informar manualmente.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP não encontrado. Verifique o CEP informado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCep = false;
          _isLoadingGeocoding = false;
        });
      }
    }
  }
  
  Future<void> _updateGeocoding() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;
    
    setState(() => _isLoadingGeocoding = true);
    
    try {
      final coordinates = await GeocodingService.getCoordinatesFromAddress(address);
      
      if (coordinates != null) {
        setState(() {
          _latitude = coordinates['latitude'];
          _longitude = coordinates['longitude'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coordenadas atualizadas! ✅'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível obter coordenadas do endereço.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar coordenadas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGeocoding = false);
      }
    }
  }
  
  Future<void> _selectOpeningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _openingTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _openingTime = picked;
      });
    }
  }
  
  Future<void> _selectClosingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _closingTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _closingTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null || user.type != UserType.business) {
        throw Exception('Usuário não autenticado como empresa');
      }

      // Salvar Provider antes de qualquer await
      final establishmentProvider = Provider.of<EstablishmentProvider>(context, listen: false);

      // Upload da imagem para Firebase Storage
      String imageUrl = '';
      if (_selectedImage != null) {
        try {
          imageUrl = await FirebaseService.uploadEstablishmentImage(
            _selectedImage!,
            DateTime.now().millisecondsSinceEpoch.toString(),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao fazer upload da imagem: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      // Validar coordenadas
      if (_latitude == null || _longitude == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, busque o endereço pelo CEP para obter as coordenadas automaticamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Validar dias da semana
      if (_selectedDays.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecione pelo menos um dia de funcionamento.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Validar horários
      if (_openingTime == null || _closingTime == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, informe o horário de funcionamento.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Calcular isOpen baseado no horário e dias
      final calculatedIsOpen = Establishment.calculateIsOpen(
        '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}',
        '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}',
        _selectedDays.toList(),
      );
      
      var establishment = Establishment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        distance: 0.0,
        avatarUrl: imageUrl,
        difficultyLevel: DifficultyLevel.popular, // Valor padrão - será definido pelo admin depois
        dietaryOptions: _selectedDietaryOptions.toList(),
        isOpen: calculatedIsOpen,
        ownerId: user.id,
        address: _addressController.text.trim(),
        openingTime: '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}',
        closingTime: '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}',
        openingDays: _selectedDays.toList(),
      );

      // Salvar no Firestore (com timeout)
      String? savedId;
      try {
        savedId = await FirebaseService.saveEstablishment(establishment).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Timeout ao salvar estabelecimento. Verifique sua conexão.');
          },
        );
        
        // Atualizar o ID do estabelecimento com o ID retornado pelo Firestore
        if (savedId != null && savedId != establishment.id) {
          establishment = Establishment(
            id: savedId,
            name: establishment.name,
            category: establishment.category,
            latitude: establishment.latitude,
            longitude: establishment.longitude,
            distance: establishment.distance,
            avatarUrl: establishment.avatarUrl,
            difficultyLevel: establishment.difficultyLevel,
            dietaryOptions: establishment.dietaryOptions,
            isOpen: establishment.isOpen,
            ownerId: establishment.ownerId,
            address: establishment.address,
            openingTime: establishment.openingTime,
            closingTime: establishment.closingTime,
            openingDays: establishment.openingDays,
          );
        }
        
        // Se a URL da imagem mudou após upload, atualizar no Firestore
        if (imageUrl.isNotEmpty && imageUrl != establishment.avatarUrl && savedId != null) {
          try {
            await FirebaseService.updateEstablishment(savedId, {'avatarUrl': imageUrl}).timeout(
              const Duration(seconds: 5),
            );
            // Atualizar o estabelecimento local com a nova URL
            establishment = Establishment(
              id: establishment.id,
              name: establishment.name,
              category: establishment.category,
              latitude: establishment.latitude,
              longitude: establishment.longitude,
              distance: establishment.distance,
              avatarUrl: imageUrl,
              difficultyLevel: establishment.difficultyLevel,
              dietaryOptions: establishment.dietaryOptions,
              isOpen: establishment.isOpen,
              ownerId: establishment.ownerId,
              address: establishment.address,
              openingTime: establishment.openingTime,
              closingTime: establishment.closingTime,
              openingDays: establishment.openingDays,
            );
          } catch (e) {
            debugPrint('⚠️ Erro ao atualizar URL da imagem (não crítico): $e');
          }
        }
        
        // Adicionar imediatamente à lista local (sem esperar reload)
        establishmentProvider.addEstablishment(establishment);
        
        // Recarregar estabelecimentos no provider (em background, não crítico)
        try {
          establishmentProvider.reloadEstablishments().timeout(
            const Duration(seconds: 5),
          ).catchError((e) {
            debugPrint('⚠️ Erro ao recarregar estabelecimentos (não crítico): $e');
          });
        } catch (e) {
          debugPrint('⚠️ Erro ao recarregar estabelecimentos (não crítico): $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estabelecimento cadastrado com sucesso! ✅'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      } on TimeoutException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timeout: ${e.message}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Estabelecimento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload de foto
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.restaurant, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        onPressed: _showImageSourceDialog,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Estabelecimento *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Categoria
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Restaurante, Padaria, Café...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe a categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // CEP
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CEP *',
                        border: const OutlineInputBorder(),
                        hintText: '00000-000',
                        suffixIcon: _isLoadingCep
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchCep,
                              ),
                      ),
                      onChanged: (value) {
                        // Formatar CEP automaticamente
                        final cleanCep = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanCep.length <= 8) {
                          String formatted = cleanCep;
                          if (cleanCep.length > 5) {
                            formatted = '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
                          }
                          if (formatted != value) {
                            _cepController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        }
                        
                        // Buscar automaticamente quando tiver 8 dígitos
                        if (cleanCep.length == 8) {
                          _searchCep();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _addressNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                        hintText: '123',
                      ),
                      onChanged: (value) {
                        // Atualizar endereço quando número mudar
                        if (_addressController.text.isNotEmpty && value.isNotEmpty) {
                          // Reformatar endereço com novo número
                          final cep = _cepController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
                          if (cep.length == 8) {
                            // Buscar CEP novamente para atualizar com o número
                            _searchCep();
                          } else {
                            // Se não tem CEP válido, apenas atualizar geocoding
                            _updateGeocoding();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Endereço (preenchido automaticamente)
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Endereço *',
                  border: const OutlineInputBorder(),
                  hintText: 'Será preenchido automaticamente pelo CEP',
                  suffixIcon: _isLoadingGeocoding
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _updateGeocoding,
                          tooltip: 'Atualizar coordenadas',
                        ),
                ),
                maxLines: 2,
                readOnly: true,
              ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Coordenadas: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Dias da semana
              const Text(
                'Dias de Funcionamento *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDayChip(0, 'Dom'),
                  _buildDayChip(1, 'Seg'),
                  _buildDayChip(2, 'Ter'),
                  _buildDayChip(3, 'Qua'),
                  _buildDayChip(4, 'Qui'),
                  _buildDayChip(5, 'Sex'),
                  _buildDayChip(6, 'Sáb'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Horário de funcionamento
              const Text(
                'Horário de Funcionamento *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectOpeningTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Abertura',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  _openingTime != null
                                      ? '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Selecione',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectClosingTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fechamento',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  _closingTime != null
                                      ? '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Selecione',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Opções dietéticas
              const Text(
                'Opções Dietéticas Disponíveis:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DietaryFilter.values.map((filter) {
                  return FilterChip(
                    label: Text(filter.getLabel(context)),
                    selected: _selectedDietaryOptions.contains(filter),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDietaryOptions.add(filter);
                        } else {
                          _selectedDietaryOptions.remove(filter);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Botão de cadastrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cadastrar Estabelecimento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDayChip(int day, String label) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
    );
  }
}

