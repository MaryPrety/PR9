import 'package:flutter/material.dart';
import '../models/manga_item.dart';
import '../services/api_service.dart';

const Color primaryColor = Color(0xFFC84B31);
const Color secondaryColor = Color(0xFFECDBBA);
const Color textColor = Color(0xFF56423D);
const Color backgroundColor = Color(0xFF191919);

class EditMangaPage extends StatefulWidget {
  final MangaItem mangaItem;
  final ValueChanged<MangaItem?> onItemUpdated;

  const EditMangaPage({Key? key, required this.mangaItem, required this.onItemUpdated}) : super(key: key);

  @override
  _EditMangaPageState createState() => _EditMangaPageState();
}

class _EditMangaPageState extends State<EditMangaPage> {
  late TextEditingController _volumeController;
  late TextEditingController _chaptersController;
  late TextEditingController _priceController;
  late TextEditingController _fullDescriptionController;
  late TextEditingController _formatController;
  late TextEditingController _publisherController;
  late List<String> _imageLinks;
  bool _isSubmitting = false;

  final List<String> formatTexts = [
    'Твердый переплет\nФормат издания 19.6 x 12.5 см\nкол-во стр от 380 до 400',
    'Мягкий переплет\nФормат издания 18.0 x 11.0 см\nкол-во стр от 350 до 370',
    'Электронная версия\nФормат издания 19.6 x 12.5 см\nкол-во стр от 380 до 400',
  ];

  final List<String> publisherTexts = [
    'Издательство Терлецки Комикс',
    'Издательство Другое Комикс',
    'Издательство Еще Комикс',
    'Alt Graph',
  ];

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(text: widget.mangaItem.title);
    _chaptersController = TextEditingController(text: widget.mangaItem.chapters);
    _priceController = TextEditingController(text: widget.mangaItem.price);
    _fullDescriptionController = TextEditingController(text: widget.mangaItem.description);
    _formatController = TextEditingController(text: widget.mangaItem.format);
    _publisherController = TextEditingController(text: widget.mangaItem.publisher);
    _imageLinks = List.from(widget.mangaItem.additionalImages)..insert(0, widget.mangaItem.imagePath);
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _chaptersController.dispose();
    _priceController.dispose();
    _fullDescriptionController.dispose();
    _formatController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    return _volumeController.text.isNotEmpty &&
           _chaptersController.text.isNotEmpty &&
           _priceController.text.isNotEmpty &&
           _fullDescriptionController.text.isNotEmpty &&
           _formatController.text.isNotEmpty &&
           _publisherController.text.isNotEmpty &&
           _imageLinks.length == 3;
  }

  Future<void> _submit() async {
    if (_validateInputs()) {
      setState(() => _isSubmitting = true);

      final updatedItem = MangaItem(
        id: widget.mangaItem.id,
        imagePath: _imageLinks[0],
        title: _volumeController.text,
        description: _fullDescriptionController.text,
        price: _priceController.text,
        additionalImages: _imageLinks.sublist(1),
        format: _formatController.text,
        publisher: _publisherController.text,
        chapters: _chaptersController.text,
      );

      try {
        // Отправляем данные через PUT запрос для обновления
        final result = await ApiService().updateProduct(updatedItem);
        widget.onItemUpdated(result);
        Navigator.pop(context, result);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении товара: $error')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля и добавьте ровно 3 изображения")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Редактировать том", style: TextStyle(fontFamily: 'Russo One')),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "MANgo100+",
                      style: TextStyle(color: primaryColor, fontSize: 36, fontFamily: 'Russo One'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField('Какой том', _volumeController, hintText: 'Например, Том 1'),
                    const SizedBox(height: 15),
                    _buildInputField('Главы', _chaptersController, hintText: 'Например, № глав: 1-36 + дополнительные истории'),
                    const SizedBox(height: 15),
                    _buildInputField('Цена', _priceController, hintText: 'Например, 100 рублей', keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildDropdownField('Формат издания', _formatController, formatTexts),
                    const SizedBox(height: 15),
                    _buildDropdownField('Издательство', _publisherController, publisherTexts),
                    const SizedBox(height: 15),
                    _buildImageSelection(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Обновить", style: TextStyle(fontSize: 20, fontFamily: 'Russo One')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {String? hintText, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items) {
    return DropdownButtonFormField<String>(
      value: items.contains(controller.text) ? controller.text : null,
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Добавьте изображения", style: TextStyle(color: textColor)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < _imageLinks.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(
                      _imageLinks[i],
                      width: 60,
                      height: 60,
                    ),
                    if (i == 0) ...[
                      IconButton(
                        onPressed: () {
                          // При необходимости добавить логику для изменения изображения
                        },
                        icon: const Icon(Icons.edit, color: primaryColor),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}