require 'sqlite3'
require 'json'

class User
  attr_accessor :id, :firstname, :lastname, :age, :password, :email

  def initialize(id=0, firstname='', lastname='', age=0, password='', email='')
    @id = id
    @firstname = firstname
    @lastname = lastname
    @age = age
    @password = password
    @email = email
  end

  def self.connection
    begin
      @db = SQLite3::Database.open 'db.sql'
      @db.results_as_hash = true
      @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        firstname TEXT,
        lastname TEXT,
        age INTEGER,
        password TEXT,
        email TEXT
      );
      SQL
      return @db
    rescue SQLite3::Exception => e
      puts "Error Occurred: #{e}"
      return nil
    end
  end

  def self.create(user_info)
    @db = self.connection
    return nil unless @db
    @db.execute("INSERT INTO users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)",
                [user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email]])
    userData = User.new(@db.last_insert_row_id, user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email])
    @db.close if @db
    return userData
  end

  def self.find(user_id)
    @db = self.connection
    return nil unless @db
    getUser = @db.execute("SELECT * FROM users WHERE id = ?", user_id)
    if getUser.any?
      userData = User.new(getUser[0]["id"], getUser[0]["firstname"], getUser[0]["lastname"], getUser[0]["age"], getUser[0]["password"], getUser[0]["email"])
    else
      userData = nil
    end
    @db.close if @db
    return userData
  end

  def self.all
    @db = self.connection
    return [] unless @db
    allUsers = @db.execute("SELECT * FROM users")
    @db.close if @db
    return allUsers
  end

  def self.update(user_id, attribute, value)
    @db = self.connection
    return nil unless @db
    @db.execute("UPDATE users SET #{attribute} = ? WHERE id = ?", [value, user_id])
    updatedUser = @db.execute("SELECT * FROM users WHERE id = ?", user_id)
    @db.close if @db
    return updatedUser
  end

  def self.authentication(password, email)
    @db = self.connection
    return nil unless @db
    authUser = @db.execute("SELECT * FROM users WHERE email = ? AND password = ?", [email, password])
    @db.close if @db
    return authUser
  end

  def self.destroy(user_id)
    @db = self.connection
    return false unless @db
    begin
      @db.execute("DELETE FROM users WHERE id = ?", user_id)
      @db.close if @db
      return true
    rescue SQLite3::Exception => e
      puts "Error occurred during deletion: #{e}"
      @db.close if @db
      return false
    end
  end
end
