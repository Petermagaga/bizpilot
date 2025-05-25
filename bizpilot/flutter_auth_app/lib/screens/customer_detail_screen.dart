import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _customer;
  bool _loading = true;
  String? _error;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _notesController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCustomer();
  }

  Future<void> _fetchCustomer() async {
    try {
      final customer = await ApiService().getCustomerById(widget.customerId);
      setState(() {
        _customer = customer;
        _loading = false;
      });

      // Initialize controllers AFTER customer is fetched
      _nameController = TextEditingController(text: customer.name);
      _emailController = TextEditingController(text: customer.email);
      _phoneController = TextEditingController(text: customer.phone);
      _companyController = TextEditingController(text: customer.company);
      _notesController = TextEditingController(text: customer.notes);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = Customer(
        id: _customer!.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        company: _companyController.text,
        notes: _notesController.text,
        createdAt: _customer!.createdAt,
      );

      try {
        await ApiService().updateCustomer(widget.customerId, updatedCustomer);
        setState(() {
          _customer = updatedCustomer;
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  Widget _buildStaticView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text('Name: ${_customer!.name}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Email: ${_customer!.email}'),
          const SizedBox(height: 8),
          Text('Phone: ${_customer!.phone}'),
          const SizedBox(height: 8),
          Text('Company: ${_customer!.company}'),
          const SizedBox(height: 8),
          Text('Notes: ${_customer!.notes}'),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Enter name' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value!.isEmpty ? 'Enter email' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitUpdate,
              child: const Text('Save Changes'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Detail'),
        actions: [
          if (_customer != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _customer == null
                  ? const Center(child: Text('Customer not found'))
                  : _isEditing
                      ? _buildEditForm()
                      : _buildStaticView(),
    );
  }
}
