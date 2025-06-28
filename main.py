import psycopg2
from psycopg2 import Error

def connect_to_postgres():
    """Connect to PostgreSQL database and execute sample queries with rollback support"""
    connection = None # inicializa la conexion como none para asegurar que no se usa antes de establecerla.
    cursor = None
    
    try:
        # parametros de conexion
        connection_params = {
            'host': 'localhost',
            'database': 'taller4',
            'user': 'postgres',
            'password': 'postgres',
            'port': 5432
        }
        
        # Establish connection
        connection = psycopg2.connect(**connection_params) # unpacks the dictionary into keyword arguments
        cursor = connection.cursor()
        
        print("✅ Successfully connected to PostgreSQL database")
        
        # Print PostgreSQL version
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()
        print(f"📊 PostgreSQL version: {db_version[0]}")
        
        # Example 1: Create a sample table (with transaction)
        print("\n🔧 Creating sample table...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS employees (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                department VARCHAR(50),
                salary DECIMAL(10, 2),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # Example 2: Insert sample data
        print("📝 Inserting sample data...")
        insert_query = """
            INSERT INTO employees (name, email, department, salary) 
            VALUES (%s, %s, %s, %s)
        """
        sample_data = [
            ('John Doe', 'john.doe@company.com', 'asd', 75000.00),
            ('Jane Smith', 'jane.smith@company.com', 'Marketing', 65000.00),
            ('Bob Johnson', 'bob.johnson@company.com', 'Engineering', 80000.00)
        ]
        
        cursor.executemany(insert_query, sample_data)
        print(f"✅ Inserted {cursor.rowcount} rows")
        
        # Example 3: Query data
        print("\n📋 Querying employees:")
        cursor.execute("""
            SELECT id, name, email, department, salary 
            FROM employees 
            ORDER BY salary DESC
        """)
        
        rows = cursor.fetchall() # obtenemos todas las filas de la consulta
        print(f"{'ID':<3} {'Name':<15} {'Email':<25} {'Department':<12} {'Salary':<10}")
        print("-" * 70)
        for row in rows:
            print(f"{row[0]:<3} {row[1]:<15} {row[2]:<25} {row[3]:<12} ${row[4]:<9}")
        
        # Example 4: Update with transaction demonstration
        print("\n🔄 Demonstrating transaction with rollback...")
        
        # Start a savepoint for demonstration
        cursor.execute("SAVEPOINT demo_savepoint")
        
        
        try:
            # Update salary
            cursor.execute("""
                UPDATE employees 
                SET salary = salary * 1.1 
                WHERE department = 'Engineering'
            """)
            print(f"📈 Updated {cursor.rowcount} Engineering salaries (+10%)")
            
            # Query updated data
            cursor.execute("""
                SELECT name, salary 
                FROM employees 
                WHERE department = 'Engineering'
            """)
            updated_rows = cursor.fetchall()
            print("Updated Engineering salaries:")
            for row in updated_rows:
                print(f"  {row[0]}: ${row[1]}")
            
            # Demonstrate rollback
            print("\n🔙 Rolling back salary changes...")
            cursor.execute("ROLLBACK TO SAVEPOINT demo_savepoint")
            
            # Verify rollback
            cursor.execute("""
                SELECT name, salary 
                FROM employees 
                WHERE department = 'Engineering'
            """)
            original_rows = cursor.fetchall()
            print("Salaries after rollback:")
            for row in original_rows:
                print(f"  {row[0]}: ${row[1]}")
            
        except Error as e:
            print(f"❌ Error during transaction: {e}")
            cursor.execute("ROLLBACK TO SAVEPOINT demo_savepoint")
        
        # Commit the successful operations (table creation and inserts)
        connection.commit()
        print("\n✅ Transaction committed successfully")
        
        # Example 5: Aggregate query
        print("\n📊 Department statistics:")
        cursor.execute("""
            SELECT 
                department,
                COUNT(*) as employee_count,
                AVG(salary) as avg_salary,
                MAX(salary) as max_salary,
                MIN(salary) as min_salary
            FROM employees 
            GROUP BY department
            ORDER BY avg_salary DESC
        """)
        
        stats = cursor.fetchall()
        print(f"{'Department':<12} {'Count':<6} {'Avg Salary':<12} {'Max Salary':<12} {'Min Salary':<12}")
        print("-" * 65)
        for stat in stats:
            print(f"{stat[0]:<12} {stat[1]:<6} ${stat[2]:<11.2f} ${stat[3]:<11.2f} ${stat[4]:<11.2f}")
        
    except Error as e:
        print(f"❌ Error while connecting to PostgreSQL: {e}")
        if connection:
            connection.rollback()
            print("🔙 Transaction rolled back due to error")
    
    finally:
        # Clean up connections
        if cursor:
            cursor.close()
        if connection:
            connection.close()
            print("\n🔌 PostgreSQL connection closed")

def cleanup_demo_data():
    """Optional: Clean up demo data"""
    connection = None
    cursor = None
    
    try:
        connection_params = {
            'host': 'localhost',
            'database': 'postgres',
            'user': 'postgres',
            'password': 'postgres',
            'port': 5432
        }
        
        connection = psycopg2.connect(**connection_params)
        cursor = connection.cursor()
        
        cursor.execute("DROP TABLE IF EXISTS employees")
        connection.commit()
        print("🧹 Demo table cleaned up")
        
    except Error as e:
        print(f"❌ Error during cleanup: {e}")
    
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

if __name__ == "__main__":
    print("🚀 Starting PostgreSQL Connection Demo")
    print("=" * 50)
    
    connect_to_postgres()
    
    # Uncomment the line below if you want to clean up the demo data
    # cleanup_demo_data()
