import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';




class CreateTaskScreen extends StatefulWidget {
  final int customerId;

  const CreateTaskScreen({super.key, required this.customerId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _dueDate;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Task Title'),
                onSaved: (value) => _title = value!,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(_dueDate == null
                      ? 'No due date'
                      : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}'),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _pickDueDate,
                    child: Text('Pick Due Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? CircularProgressIndicator()
                    : Text('Create Task'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _dueDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      await ApiService().createTask(
        widget.customerId,
        _title,
        _description,
        _dueDate!,
      );
      setState(() => _loading = false);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
