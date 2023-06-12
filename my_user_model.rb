require 'sqlite3'

# Define the User class

class User
    # Define the accessors for the instance variables
    attr_accessor :id, :firstname, :lastname, :age, :password, :email

    # the constructor method that sets the instance variables
    def initialize (id=0, firstname, lastname, age, password, email)
        @firstname=firstname
        @lastname=lastname
        @age=age
        @password=password
        @email=email
        @id=id
    end

    # a class method to connect to the database
    def self.connection()
        begin
            @db_connection = SQLite3::Database.open 'db.sql'
            @db_connection = SQLite3::Database.new 'db.sql' if !@db_connection
            @db_connection.results_as_hash = true
            @db_connection.execute "CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, firstname STRING, lastname STRING, age INTEGER, password STRING, email STRING)"
            return @db_connection
        rescue SQLite3::Exception => e
            p "Error occurred: "
            p e
        end
    end

    # a class method to create a new user
    def self.create(user_info)
        @firstname = user_info[:firstname]
        @lastname = user_info[:lastname]
        @age = user_info[:age]
        @password = user_info[:password]
        @email = user_info[:email]

        # connects to the database
        @db_connection = self.connection
        @db_connection.execute "INSERT INTO users(firstname, lastname, age, password, email) VALUES(?,?,?,?,?)", @firstname, @lastname, @age, @password, @email
        user=User.new(@firstname, @lastname, @age, @password, @email)
        user.id = @db_connection.last_insert_row_id
        @db_connection.close
        return user
    end

    # a class method that searches for a user in the database
    def self.find(user_id)
        @db_connection = self.connection
        user = @db_connection.execute "SELECT * FROM users WHERE id = ?", user_id
        user_info=User.new(user[0]["firstname"], user[0]["lastname"], user[0]["age"], user[0]["password"], user[0]["email"])
        @db_connection.close
        return user_info
    end

    # a class method that displays all users in a database
    def self.all()
        @db_connection = self.connection()
        user = @db_connection.execute "SELECT * FROM users"
        @db_connection.close
        return user
    end

    # a class method that updates an attribute of a user with another value
    def self.update(user_id, attribute, value)
        @db_connection = self.connection
        @db_connection.execute "UPDATE users SET #{attribute} = ? WHERE id = ?", value, user_id
        user = @db_connection.execute "SELECT * FROM users WHERE id = ?", user_id
        @db_connection.close
        return user
    end

    # a class method that deletes a specific user in the database
    def self.destroy(user_id)
        @db_connection = self.connection()
        delete_user = @db_connection.execute "DELETE FROM users WHERE id = #{user_id}"
        @db_connection.close
        return delete_user
    end

    def self.auth(password, email)
        @db_connection = self.connection
        user = @db_connection.execute "SELECT * FROM users WHERE email = ? AND password = ?", email, password
        @db_connection.close
        return user
    end
end
