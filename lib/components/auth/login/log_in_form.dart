import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/components/auth/login/log_in_service.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
import 'package:tecnyapp_flutter/widgets/my_textfield.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  LogInFormState createState() => LogInFormState();
}

class LogInFormState extends State<LogInForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  bool _isLoading = false;
  bool termsConditions = false;

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Términos y Condiciones"),
          content: const SingleChildScrollView(
            child: Text(
              '''El acceso y la utilización de las aplicaciones móviles incluyendo, sin limitar a: Moresa 2022, Fritec 2022, Race 2022, TF Victor 2022, BioCeramic 2022 y Moresa Diesel así como sus actualizaciones como futuras aplicaciones, en adelante “las aplicaciones” así como los sitios web donde se hospeden los Términos y Condiciones, son propiedad y responsabilidad de Grupo Kuo, S.A.B. de C.V. en adelante “Nosotros” o “Grupo Kuo”. Nosotros tenemos domicilio en Paseo de los Tamarindos 400- B, Piso 31, Bosque de las Lomas México, CDMX, C.P. 05120. Los medios de contacto son: 555726- 8200 y el correo electrónico: kuo.refacciones@kuoafmkt.com.
              Los Términos y Condiciones de las aplicaciones, en adelante “Términos y Condiciones” o “Documento” o “Contrato” regulan el uso, manejo, control de las aplicaciones (móviles o de escritorio) que utilizan el sitio web o las páginas o sitios hospedados ubicados o ligados al o en el mismo que ofrecen servicios de catalogo y proveen información sobre los distintos productos propiedad de Grupo Kuo.
              Los Usuarios aceptan completamente y expresamente cada una de las cláusulas que conforman los Términos y Condiciones desde el momento que utilizan la aplicación. Nos reservamos el derecho de cambiar, modificar y/o actualizar en cualquier momento las condiciones y términos establecidos en el presente documento. Podrá consultar la versión actualizada en el sitio Dacomsa sección Términos y condiciones de uso de las aplicaciones móviles. Asimismo, podrá encontrar en la parte superior la fecha de actualización del contrato para revisar cuando fueron modificadas. Por tanto, le pedimos a Usted “Usuario” revisar periódicamente y leer cuidadosamente los Términos y Condiciones.
              En caso de no estar de acuerdo con alguna cláusula o todos los términos y condiciones le rogamos que por favor no utilice la aplicación.''',
              textAlign: TextAlign.justify,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(234, 223, 193, 10),
              ),
              child: const Text(
                "Aceptar",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                termsConditions = true;
                Navigator.of(context).pop(); // Cerrar el diálogo
                // Aquí puedes agregar lógica para aceptar los términos si es necesario
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        MyTextField(
          controller: nameController,
          hintText: "Nombre y Apellido",
          obscureText: false,
          icon: Icons.person,
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: dniController,
          hintText: "DNI",
          obscureText: false,
          icon: Icons.assignment_ind,
        ),
        const SizedBox(height: 10),
        MyTextField(
          controller: phoneNumberController,
          hintText: "Número de Teléfono",
          obscureText: false,
          icon: Icons.phone,
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () {
            _showTermsAndConditionsDialog(context);
          },
          child: const Text(
            "Términos y Condiciones",
            style: TextStyle(
              color: Color.fromARGB(234, 223, 193, 10),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : MyButton(
                colorButton: Theme.of(context).colorScheme.onPrimary,
                text: "Siguiente",
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await LogInService.login(
                      context,
                      nameController.text,
                      phoneNumberController.text,
                      dniController.text,
                      termsConditions);

                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
      ],
    );
  }
}
