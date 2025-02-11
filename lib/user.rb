require_relative 'database_connection'
require 'bcrypt'

class User
  attr_reader :id, :name, :username, :email

  def initialize(id:, name:, username:, email:)
    @id = id
    @name = name
    @username = username
    @email = email
  end

  def self.create(name:, username:, email:, password:)
    encrypted_password = BCrypt::Password.create(password)
    result = DatabaseConnection.query(
      "INSERT INTO users (name, username, email, password)
      VALUES($1, $2, $3, $4) RETURNING id, name, username, email;",
      [name, username, email, encrypted_password]
    )

    User.new(
      id: result[0]['id'],
      name: result[0]['name'],
      username: result[0]['username'],
      email: result[0]['email']
    )
  end

  def self.find(id)
    return nil unless id
    result = DatabaseConnection.query(
      "SELECT * FROM users WHERE id = $1",
      [id]
    )
    
    User.new(
      id: result[0]['id'],
      name: result[0]['name'],
      username: result[0]['username'],
      email: result[0]['email']
    )
  end

  def self.authenticate(username:, password:)
    result = DatabaseConnection.query(
      "SELECT * FROM users WHERE username = $1",
      [username]
    )
    return unless result.any?
    return unless BCrypt::Password.new(result[0]['password']) == password

    User.new(
      id: result[0]['id'],
      name: result[0]['name'],
      username: result[0]['username'],
      email: result[0]['email']
    )
  end
end