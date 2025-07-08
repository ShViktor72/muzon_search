import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  // Функция для открытия ссылки
  void _launchURL() async {
    const url = 'https://yoomoney.ru/to/410014722763396';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Не удалось открыть $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поддержать проект')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Спасибо, что используете это приложение! Если хотите поддержать разработку:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              '💳 ЮMoney: 410014722763396',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text(
              'Или по ссылке:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _launchURL,
              child: const Text(
                'https://yoomoney.ru/to/410014722763396',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Спасибо за поддержку ❤️',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}