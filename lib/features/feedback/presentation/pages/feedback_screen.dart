import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_catalog/core/di/service_locator.dart';

enum FeedbackType {
  suggestion,
  bug,
  other,
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  FeedbackType _selectedType = FeedbackType.suggestion;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final String subject;
    switch (_selectedType) {
      case FeedbackType.suggestion:
        subject = 'Предложение для Movie Library';
        break;
      case FeedbackType.bug:
        subject = 'Отчет об ошибке для Movie Library';
        break;
      case FeedbackType.other:
        subject = 'Обратная связь для Movie Library';
        break;
    }

    try {
      await Services.feedback.sendEmail(
        to: 'developer@example.com',
        subject: subject,
        body: _messageController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка запуска почтового клиента: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обратная связь'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Мы будем рады услышать вас!',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Есть предложение или нашли ошибку? Дайте нам знать, чтобы мы могли улучшить приложение.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<FeedbackType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Тип обращения',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: FeedbackType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type == FeedbackType.suggestion
                          ? 'Предложение'
                          : type == FeedbackType.bug
                              ? 'Ошибка'
                              : 'Другое',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ваше сообщение',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.message_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите сообщение';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _sendFeedback,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Отправить'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


