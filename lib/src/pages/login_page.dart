// Flutter imports:
// Package imports:
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
// Project imports:
import 'package:timetable/src/bottom_sheets/settings_bottom_sheet.dart';
import 'package:timetable/src/providers/auth_provider.dart';
import 'package:timetable/src/providers/messanger_provider.dart';
import 'package:timetable/src/widgets/expanded_single_child_scroll_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginDropdownButtonFormField<T> extends StatelessWidget {
  final T? value;

  final List<DropdownMenuItem<T>>? items;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final String? hintText;
  final bool isLoading;
  final Icon? prefixIcon;
  const _LoginDropdownButtonFormField({
    Key? key,
    required this.value,
    required this.items,
    this.validator,
    this.onChanged,
    this.hintText,
    this.isLoading = false,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      value: value,
      items: items,
      validator: validator,
      onChanged: onChanged,
      iconEnabledColor: Theme.of(context).colorScheme.onSurface,
      iconDisabledColor: Theme.of(context).colorScheme.onSurface,
      selectedItemHighlightColor: Theme.of(context).highlightColor,
      decoration: InputDecoration(
        errorStyle: const TextStyle(fontWeight: FontWeight.bold),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        prefixIcon: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                    strokeWidth: 3,
                  ),
                ),
              )
            : prefixIcon != null
                ? Icon(
                    prefixIcon!.icon,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 28,
                  )
                : null,
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      hint: Text(
        hintText ?? '',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      dropdownDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      dropdownOverButton: true,
      isExpanded: true,
      iconSize: 24,
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  List<String> _academicYears = [];
  List<Group> _groups = [];

  String? _selectedAcademicYear;
  Group? _selectedGroup;

  bool _loginAsAdmin = false;
  bool _showPassword = false;
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surface,
          onRefresh: _updateAll,
          child: ExpandedSingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: AnimationLimiter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375 * 2),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 64,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: PhysicalModel(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            elevation: 2,
                            child: Form(
                              key: _formKey,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Text(
                                          'Добро пожаловать',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 78,
                                      child: AnimatedOpacity(
                                        opacity: _academicYears.isNotEmpty ? 1 : 0.5,
                                        duration: const Duration(milliseconds: 300),
                                        child: _LoginDropdownButtonFormField<String>(
                                          value: _selectedAcademicYear,
                                          items: [
                                            for (final academicYear in _academicYears)
                                              DropdownMenuItem(
                                                value: academicYear,
                                                child: Text(
                                                  academicYear,
                                                ),
                                              )
                                          ],
                                          validator: (value) {
                                            if (_academicYears.isNotEmpty && value == null) {
                                              return 'Пожалуйста, выберите учебный год';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              if (_selectedAcademicYear == value) return;

                                              _selectedAcademicYear = value;
                                              _updateGroups(_selectedAcademicYear!);
                                            });
                                          },
                                          hintText: 'Выберите учебный год',
                                          isLoading: _academicYears.isEmpty,
                                          prefixIcon: const Icon(Icons.calendar_month),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 78,
                                      child: AnimatedOpacity(
                                        opacity: _selectedAcademicYear != null && _groups.isNotEmpty ? 1 : 0.5,
                                        duration: const Duration(milliseconds: 300),
                                        child: _LoginDropdownButtonFormField<Group>(
                                          value: _selectedGroup,
                                          items: [
                                            for (final group in _groups)
                                              DropdownMenuItem(
                                                value: group,
                                                child: Text(
                                                  group.name,
                                                ),
                                              )
                                          ],
                                          validator: (value) {
                                            if (_selectedAcademicYear != null && _groups.isNotEmpty && value == null) {
                                              return 'Пожалуйста, выберите группу';
                                            }
                                            return null;
                                          },
                                          onChanged: _selectedAcademicYear != null
                                              ? (value) {
                                                  setState(() {
                                                    if (_selectedGroup == value) return;

                                                    _selectedGroup = value;
                                                  });
                                                }
                                              : null,
                                          hintText: 'Выберите группу',
                                          isLoading: _selectedAcademicYear != null && _groups.isEmpty,
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: _loginAsAdmin ? 78 : 0,
                                      curve: Curves.easeInOut,
                                      child: SingleChildScrollView(
                                        child: _LoginPasswordTextFormField(
                                          controller: _passwordController,
                                          validator: (value) {
                                            if (_loginAsAdmin && _selectedGroup != null && (value == null || value.isEmpty)) {
                                              return 'Пожалуйста, введите пароль';
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (value) => _tryLogin(),
                                          obscureText: !_showPassword,
                                          prefixIcon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _showPassword ? Icons.visibility_off : Icons.visibility,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          ),
                                          hintText: 'Введите пароль',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: Material(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(4),
                                  elevation: 2,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      _tryLogin();
                                    },
                                    child: Center(
                                      child: _loading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context).colorScheme.onSurface,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Text(
                                              'Войти',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _loginAsAdmin = !_loginAsAdmin;
                              if (_loginAsAdmin) {
                                if (_passwordController.text.isNotEmpty) {
                                  _passwordController.clear();
                                }
                                _showPassword = false;
                              }
                              FocusScope.of(context).unfocus();
                            });
                          },
                          child: Text(
                            _loginAsAdmin ? 'Войти как участник?' : 'Войти как администратор?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                SettingsBottomSheet.toggle(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.settings_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _updateAcademicYears();
  }

  Future<void> _tryLogin() async {
    if (_formKey.currentState!.validate() && !_loading && _selectedAcademicYear != null && _selectedGroup != null) {
      setState(() => _loading = true);
      LoginStatus loginStatus = await context.read<AuthProvider>().tryLogin(
            group: _selectedGroup!.name,
            academicYear: _selectedGroup!.academicYear,
            password: _loginAsAdmin ? _passwordController.text : null,
          );
      if (loginStatus == LoginStatus.ok) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/timetable', (route) => false);
        }
      } else {
        if (mounted) {
          context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка входа');
        }
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _updateAcademicYears({bool clear = true}) async {
    if (clear) {
      _academicYears.clear();
      _selectedAcademicYear = null;
      _formKey.currentState?.validate();
    }

    final newAcademicYears = await context.read<AuthProvider>().getAcademicYears();

    if (newAcademicYears == null) {
      if (mounted) {
        context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка загрузки данных');
      }
    } else {
      setState(() {
        _academicYears = newAcademicYears;
      });
    }
  }

  Future<void> _updateAll() async {
    await _updateAcademicYears(clear: false);
    if (_selectedAcademicYear != null) {
      await _updateGroups(_selectedAcademicYear!, clear: false);
    }
  }

  Future<void> _updateGroups(String academicYear, {bool clear = true}) async {
    if (clear) {
      _groups.clear();
      _selectedGroup = null;
      _formKey.currentState?.validate();
    }

    final newGroups = await context.read<AuthProvider>().getGroups(academicYear: academicYear);

    if (newGroups == null) {
      if (mounted) {
        context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка загрузки данных');
      }
    } else {
      setState(() {
        _groups = newGroups;
        if (_selectedGroup != null && _groups.any((group) => group.id == _selectedGroup!.id)) {
          _selectedGroup = _groups.firstWhere((group) => group.id == _selectedGroup!.id);
        }
      });
    }
  }
}

class _LoginPasswordTextFormField extends StatelessWidget {
  final TextEditingController? controller;

  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  const _LoginPasswordTextFormField({
    Key? key,
    this.controller,
    this.validator,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      autofocus: false,
      autocorrect: false,
      cursorColor: Theme.of(context).colorScheme.onSurface,
      decoration: InputDecoration(
        errorStyle: const TextStyle(fontWeight: FontWeight.bold),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon!.icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 28,
              )
            : null,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}
