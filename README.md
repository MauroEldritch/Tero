Tero
======

# Acerca de Tero

Tero es una aplicación para analizar filtraciones en sitios. Permite al Administrador de un sitio comprometido utilizarlo para analizar usuarios filtrados y disponibilizar en el corto plazo un sistema de consulta para los mismos; y permite a cualquier Usuario consultar y verificar si fue comprometido en dicho sitio con sólo ingresar su dirección de correo.

Tero fue creado por [Mauro Eldritch](https://github.com/mauroeldritch).


## Uso

Requiere `sinatra` y `logger`.

Configurar el nombre de la filtración y la fecha del incidente en el archivo `conf/settings.rb`.

Para analizar la filtración, crear el archivo `db/leaks.csv` conteniendo (separado por comas) cada email comprometido con su correspondiente clave, una por línea.

Siguiendo nuestra política de Full-Disclosure, Tero por defecto imprime las 10 claves más usadas y todos los dominios utilizados. Tener en cuenta este detalle antes de publicar.