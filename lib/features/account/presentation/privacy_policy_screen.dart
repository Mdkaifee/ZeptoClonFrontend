import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/account/data/repositories/content_repository.dart';
import 'package:flutter_application_1/features/account/data/models/content_page_model.dart';
import 'package:flutter_application_1/features/account/presentation/widgets/content_page_widgets.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late Future<ContentPageModel> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ContentRepository>().fetchPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: FutureBuilder<ContentPageModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ContentErrorView(
              message: 'Failed to load privacy policy. Please try again.',
              onRetry: () {
                setState(() {
                  _future =
                      context.read<ContentRepository>().fetchPrivacyPolicy();
                });
              },
            );
          }
          final content = snapshot.data;
          if (content == null) {
            return ContentErrorView(
              message: 'No privacy policy available.',
              onRetry: () {
                setState(() {
                  _future =
                      context.read<ContentRepository>().fetchPrivacyPolicy();
                });
              },
            );
          }
          return ContentPageView(content: content);
        },
      ),
    );
  }
}
