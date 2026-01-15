import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

/// Create listing screen
class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  String _unit = 'kg';
  DateTime? _expiresAt;
  DateTime? _pickupStart;
  DateTime? _pickupEnd;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement create listing via API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: DwColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DwSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos
              Text('Photos', style: DwTextStyles.titleMedium),
              const SizedBox(height: DwSpacing.sm),
              _PhotoPicker(),
              const SizedBox(height: DwSpacing.lg),

              // Title
              DwTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'What are you selling?',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DwSpacing.md),

              // Description
              DwTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your item...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DwSpacing.md),

              // Price and quantity row
              Row(
                children: [
                  Expanded(
                    child: DwTextField(
                      controller: _priceController,
                      label: 'Price',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: DwSpacing.md),
                  Expanded(
                    child: DwTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DwSpacing.md),

              // Unit selector
              Text('Unit', style: DwTextStyles.titleSmall),
              const SizedBox(height: DwSpacing.sm),
              Wrap(
                spacing: DwSpacing.sm,
                children: ['kg', 'lb', 'piece', 'box', 'bag', 'bunch'].map((unit) {
                  return ChoiceChip(
                    label: Text(unit),
                    selected: _unit == unit,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _unit = unit);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: DwSpacing.lg),

              // Expiry date
              Text('Expiry Date', style: DwTextStyles.titleMedium),
              const SizedBox(height: DwSpacing.sm),
              _DateTimePicker(
                value: _expiresAt,
                hint: 'When does this expire?',
                onChanged: (dt) => setState(() => _expiresAt = dt),
              ),
              const SizedBox(height: DwSpacing.lg),

              // Pickup window
              Text('Pickup Window', style: DwTextStyles.titleMedium),
              const SizedBox(height: DwSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _DateTimePicker(
                      value: _pickupStart,
                      hint: 'Start',
                      onChanged: (dt) => setState(() => _pickupStart = dt),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: DwSpacing.sm),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: _DateTimePicker(
                      value: _pickupEnd,
                      hint: 'End',
                      onChanged: (dt) => setState(() => _pickupEnd = dt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DwSpacing.xl),

              // Create button
              DwButton(
                onPressed: _isLoading ? null : _handleCreate,
                isLoading: _isLoading,
                child: const Text('Create Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add photo button
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: DwColors.border, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(DwRadius.md),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Pick image
              },
              borderRadius: BorderRadius.circular(DwRadius.md),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: DwColors.textSecondary),
                  SizedBox(height: DwSpacing.xs),
                  Text('Add Photo', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime> onChanged;

  const _DateTimePicker({
    this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
          );
          if (time != null) {
            onChanged(DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            ));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(DwSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: DwColors.border),
          borderRadius: BorderRadius.circular(DwRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: DwColors.textSecondary),
            const SizedBox(width: DwSpacing.sm),
            Expanded(
              child: Text(
                value != null
                    ? '${value!.day}/${value!.month} ${value!.hour}:${value!.minute.toString().padLeft(2, '0')}'
                    : hint,
                style: DwTextStyles.bodyMedium.copyWith(
                  color: value != null ? DwColors.textPrimary : DwColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
