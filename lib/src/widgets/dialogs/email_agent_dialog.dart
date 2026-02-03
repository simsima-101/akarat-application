import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/property/presentation/bloc/enquiry_bloc.dart';

/// Reusable Email Agent Dialog using Bloc for state management
Future<void> showEmailAgentDialog(
    BuildContext context, {
      required String subtitle,
      required String initialMessage,
      required Future<void> Function({
      required String name,
      required String email,
      required String phone,
      required String message,
      }) onSubmit,
    }) async {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController(text: initialMessage);
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (dialogContext) => BlocListener<EnquiryBloc, EnquiryState>(
      listener: (context, state) {
        if (state is EnquirySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Enquiry sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(dialogContext); // Close dialog on success
        } else if (state is EnquiryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Failed to send enquiry'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Email Agent'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone *'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message (optional)'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          BlocBuilder<EnquiryBloc, EnquiryState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is EnquiryLoading
                    ? null
                    : () {
                  if (!formKey.currentState!.validate()) return;

                  onSubmit(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    message: messageController.text.trim(),
                  );
                },
                child: state is EnquiryLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Send'),
              );
            },
          ),
        ],
      ),
    ),
  );

  // Clean up controllers after dialog closes
  nameController.dispose();
  emailController.dispose();
  phoneController.dispose();
  messageController.dispose();
}