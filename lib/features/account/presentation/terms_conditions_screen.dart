import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/account/data/models/content_page_model.dart';
import 'package:flutter_application_1/features/account/data/repositories/content_repository.dart';
import 'package:flutter_application_1/features/account/presentation/widgets/content_page_widgets.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState
    extends State<TermsAndConditionsScreen> {
  late Future<ContentPageModel> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ContentRepository>().fetchTermsAndConditions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: FutureBuilder<ContentPageModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ContentErrorView(
              message: 'Failed to load terms & conditions. Please try again.',
              onRetry: () {
                setState(() {
                  _future = context
                      .read<ContentRepository>()
                      .fetchTermsAndConditions();
                });
              },
            );
          }
          final content = snapshot.data;
          if (content == null) {
            return ContentErrorView(
              message: 'No terms & conditions available.',
              onRetry: () {
                setState(() {
                  _future = context
                      .read<ContentRepository>()
                      .fetchTermsAndConditions();
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
