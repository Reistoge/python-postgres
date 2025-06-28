# Conectarse a una base de datos PGSQL con python psycopg2

Requisitos:

- Python 3.6 o superior

- Postgresql instalado

Si estas usando vscode te recomiendo instalar estas extensiones de postgres, para que puedas ver los errores y las consultas SQL.
- [SQLTools PostgreSQL/Cockroach Driver](https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-pg)
- [DBML y ERD](https://marketplace.visualstudio.com/items?itemName=bocovo.dbml-erd-visualizer)

## 1. Crear una base de datos en Postgresql con psql:

- Abrir la terminal y ejecutar el comando:
  ```bash
  psql -U "nombre_usuario"
  ```
- dentro de psql crear una base de datos:
  ```sql
    CREATE DATABASE nombre_base_datos;
  ```
- salir de psql con:
  ```sql
      \q
  ```

más comandos psql: https://www.geeksforgeeks.org/postgresql-psql-commands/

## 2. Una vez creada la base de datos, instalar el paquete psycopg2:

Puedes instalarlo dentro en un [entorno virtual](https://github.com/Reistoge/Virtual-Environment-Tutorial) o directamente en tu sistema. Para instalarlo, ejecuta el siguiente comando en la terminal:

```bash
pip install psycopg2
```

## 3. Crear un archivo Python para conectarse a la base de datos:

```python
import psycopg2
def connect_to_db():
    try: # Intenta conectar a la base de datos siempre con try para capturar errores.
        # Conectar a la base de datos
        connection = psycopg2.connect(
            dbname="nombre_base_datos",
            user="nombre_usuario",
            password="tu_contraseña",
            host="localhost",
            port="5432"
        )

        print("Conexión exitosa a la base de datos")

        
        cursor = connection.cursor() # Crear un cursor para ejecutar consultas

        execute_query()  # Llamar a la función para ejecutar consultas
        # Aquí puedes ejecutar tus consultas SQL
        
        # Cerrar el cursor y la conexión
        cursor.close()
        connection.close()

    except Exception as e:
        print(f"Error al conectar a la base de datos: {e}")
```

## 4 rollbacks, commit y savepoints.

- los rollbacks son una forma de deshacer cambios en la base de datos. Si algo sale mal, puedes revertir los cambios desde la primra consulta hasta sql ejecutada en psycopg2 ejecutas lo ejecutas con `connection.rollback()`.

* commit es una forma de guardar los cambios en la base de datos. Si todo sale bien, puedes guardar los cambios
  con `connection.commit()`

* savepoints son puntos de guardado dentro de una transacción. Puedes crear un savepoint y luego hacer un rollback a ese savepoint si algo sale mal.
  para crear un savepoint, ejecutas `cursor.execute("SAVEPOINT nombre_savepoint")` y para hacer rollback a ese savepoint, ejecutas `cursor.execute("ROLLBACK TO SAVEPOINT nombre_savepoint")`.

`OJO` que los savepoints son destruidos una vez que haces un commit, aun asi puedes hacer rollback a un savepoint que ya no existe, pero te dara un error.

## 5 uso del cursor para ejecutar consultas SQL :

```python
def execute_query():
    try : # siempre intenta usar un try para ejecutar las queries.
        cursor.execute("SELECT * FROM nombre_tabla") # Ejecuta una consulta SQL, comienzo de la transacción
        rows = cursor.fetchall()  # Obtiene todas las filas del resultado
    for row in rows:
        print(row)  # Imprime cada fila
    except Exception as e: # si falla la consulta, captura el error y hacemos rolback
        print(f"Error al ejecutar la consulta: {e}")
        cursor.rollback()  # Deshace los cambios si hay un error

```
