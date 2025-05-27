import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'create_task_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({Key? key, required this.customerId})
    : super(key: key);

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

  List<Map<String, dynamic>> _tasks = [];
  bool _loadingTasks = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchCustomer();
    if (_customer != null) {
      await _fetchTasks();
    }
  }

  Future<void> _deleteCustomer() async {
    setState(() => _loading = true);
    try {
      await ApiService().deleteCustomer(_customer!.id);
      setState(() => _loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Customer deleted')));

      Navigator.of(context).pop(); // Go back to customer list
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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

  Future<void> _fetchTasks() async {
    if (_customer == null) return;
    try {
      final tasks = await ApiService().getTasksForCustomer(_customer!.id);
      setState(() {
        _tasks = tasks;
        _loadingTasks = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() => _loadingTasks = false);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Customer'),
            content: Text('Are you sure you want to delete this customer?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _deleteCustomer();
    }
  }

  Widget _buildStaticView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            'Name: ${_customer!.name}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text('Email: ${_customer!.email}'),
          const SizedBox(height: 8),
          Text('Phone: ${_customer!.phone}'),
          const SizedBox(height: 8),
          Text('Company: ${_customer!.company}'),
          const SizedBox(height: 8),
          Text('Notes: ${_customer!.notes}'),

          Text(
            'Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _loadingTasks
              ? CircularProgressIndicator()
              : _tasks.isEmpty
              ? Text('No tasks found.')
              : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    child: ListTile(
                      title: Text(task['title'] ?? 'No Title'),
                      subtitle: Text(task['description'] ?? ''),
                      trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(task['due_date'] ?? 'No date'),
                                const SizedBox(height: 4),
                                if (!task['is_completed']) IconButton(icon: Icon(Icons.check_circle, color: Colors.green,),
                                onPressed: () => _completeTask(task['id']),
                                ),

                              ],
                      ),
                      
                    ),
                  );
                },
              ),
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
            ),

            ElevatedButton.icon(
              onPressed: _confirmDelete,
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text('Delete Customer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _completeTask(int taskId) async {
      try {
        await ApiService().markTaskComplete(taskId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task marked as complete")));
        _fetchTasks(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to complete task")));
      }
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
            ),
        ],
      ),

      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _customer == null
                ? const Center(child: Text('Customer not found'))
                : _isEditing
                ? _buildEditForm()
                : _buildStaticView(),
      ),

      floatingActionButton:
          _loading || _customer == null
              ? null // hide FAB while loading or if no customer
              : FloatingActionButton(
                onPressed: () async {
                  final success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              CreateTaskScreen(customerId: _customer!.id!),
                    ),
                  );

                  if (success == true) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Task created')));
                  }
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, color: Colors.white),
              ),
    );
  }
}
