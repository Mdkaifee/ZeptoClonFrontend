import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/addresses/cubit/addresses_cubit.dart';
import 'package:flutter_application_1/features/addresses/cubit/addresses_state.dart';
import 'package:flutter_application_1/features/addresses/data/models/address_model.dart';
import 'package:flutter_application_1/features/auth/data/models/user_model.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({required this.user, super.key});

  final UserModel user;

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  late final AddressesCubit _addressesCubit;

  @override
  void initState() {
    super.initState();
    _addressesCubit = context.read<AddressesCubit>()
      ..loadAddresses(widget.user.id);
  }

  Future<void> _refresh() async {
    await _addressesCubit.refresh();
  }

  Future<void> _showAddressSheet({AddressModel? address}) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _AddressFormSheet(
          user: widget.user,
          initialAddress: address,
        );
      },
    );

    if (!mounted || result == null) return;

    if (address == null) {
      await _addressesCubit.addAddress(
        userId: widget.user.id,
        payload: result,
      );
    } else {
      await _addressesCubit.updateAddress(
        userId: widget.user.id,
        addressId: address.id,
        payload: result,
      );
    }
  }

  Future<void> _confirmDelete(AddressModel address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Do you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _addressesCubit.deleteAddress(
        userId: widget.user.id,
        addressId: address.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressesCubit, AddressesState>(
      listener: (context, state) {
        if (state.infoMessage != null && state.infoMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.infoMessage!)),
          );
          _addressesCubit.resetMessages();
        } else if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          _addressesCubit.resetMessages();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Saved Addresses')),
        body: BlocBuilder<AddressesCubit, AddressesState>(
          builder: (context, state) {
            if (state.status == AddressesStatus.loading &&
                state.addresses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AddressesStatus.failure &&
                state.addresses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Failed to load addresses.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.addresses.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 80),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You have no saved addresses yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showAddressSheet(),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Add New Address'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = state.addresses[index];
                  final isPending =
                      state.isMutating && state.pendingAddressId == address.id;
                  return _AddressCard(
                    address: address,
                    isPending: isPending,
                    onEdit: () => _showAddressSheet(address: address),
                    onDelete: () => _confirmDelete(address),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddressSheet(),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add Address'),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isPending,
    required this.onEdit,
    required this.onDelete,
  });

  final AddressModel address;
  final bool isPending;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isPending)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit address',
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete address',
                        onPressed: onDelete,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.buildingName),
            Text('${address.area}${address.landmark != null && address.landmark!.isNotEmpty ? ', ${address.landmark}' : ''}'),
            Text('${address.city}, ${address.state} - ${address.pincode}'),
            const SizedBox(height: 8),
            if ((address.receiverName ?? '').isNotEmpty)
              Text('Receiver: ${address.receiverName}'),
            if ((address.phone ?? '').isNotEmpty)
              Text('Phone: ${address.phone}'),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet({
    required this.user,
    this.initialAddress,
  });

  final UserModel user;
  final AddressModel? initialAddress;

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  static const List<String> _labelOptions = <String>['Home', 'Work', 'Other'];
  late final TextEditingController _buildingNameController;
  late final TextEditingController _areaController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _stateController;
  late final TextEditingController _labelController;
  late final TextEditingController _receiverNameController;
  late final TextEditingController _phoneController;
  late String _labelSelection;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAddress;
    _buildingNameController =
        TextEditingController(text: initial?.buildingName ?? '');
    _areaController = TextEditingController(text: initial?.area ?? '');
    _landmarkController = TextEditingController(text: initial?.landmark ?? '');
    _cityController = TextEditingController(text: initial?.city ?? '');
    _pincodeController = TextEditingController(text: initial?.pincode ?? '');
    _stateController = TextEditingController(text: initial?.state ?? '');
    final initialLabel = initial?.label ?? 'Home';
    if (_labelOptions.contains(initialLabel)) {
      _labelSelection = initialLabel;
      _labelController = TextEditingController();
    } else {
      _labelSelection = 'Other';
      _labelController = TextEditingController(text: initialLabel);
    }
    _receiverNameController =
        TextEditingController(text: initial?.receiverName ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _labelController.dispose();
    _receiverNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidate = true;
      });
      return;
    }

    final labelValue = _labelSelection == 'Other'
        ? _labelController.text.trim()
        : _labelSelection;

    final payload = <String, String>{
      'buildingName': _buildingNameController.text.trim(),
      'area': _areaController.text.trim(),
      'city': _cityController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'state': _stateController.text.trim(),
      'label': labelValue,
    };

    final landmark = _landmarkController.text.trim();
    if (landmark.isNotEmpty) {
      payload['landmark'] = landmark;
    }

    final receiverName = _receiverNameController.text.trim();
    if (receiverName.isNotEmpty) {
      payload['receiverName'] = receiverName;
    }

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      payload['phone'] = phone;
    }

    Navigator.of(context).pop(payload);
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.initialAddress != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode:
            _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'Edit Address' : 'Add Address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Label',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _labelOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: _labelSelection == option,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _labelSelection = option;
                        if (_labelSelection != 'Other') {
                          _labelController.clear();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (_labelSelection == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
                  validator: (value) => _requiredValidator(value, 'Label'),
                ),
              ],
              TextFormField(
                controller: _buildingNameController,
                decoration:
                    const InputDecoration(labelText: 'Building / House'),
                validator: (value) =>
                    _requiredValidator(value, 'Building / House'),
              ),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area'),
                validator: (value) => _requiredValidator(value, 'Area'),
              ),
              TextFormField(
                controller: _landmarkController,
                decoration:
                    const InputDecoration(labelText: 'Landmark (optional)'),
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => _requiredValidator(value, 'City'),
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) => _requiredValidator(value, 'State'),
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  final error = _requiredValidator(value, 'Pincode');
                  if (error != null) return error;
                  if ((value ?? '').trim().length < 4) {
                    return 'Enter a valid pincode';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _receiverNameController,
                decoration: InputDecoration(
                  labelText: 'Receiver Name (optional)',
                  hintText: widget.user.name,
                ),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: widget.user.mobile ?? '',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Save Changes' : 'Add Address'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

