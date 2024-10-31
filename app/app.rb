require 'sinatra/base'
require 'pg'
require 'json'
require 'dotenv'

Dotenv.load

class MyApp < Sinatra::Base
  configure do
    set :port, ENV['PORT'] || 8080
  
    db_params = {
      dbname: ENV['DB_NAME'] || '',
      user: ENV['DB_USER'] || '',
      password: ENV['DB_PASSWORD'] || '',
      host: ENV['DB_HOST'] || 'localhost',
      port: ENV['DB_PORT'] || 5432
    }
    set :db, PG.connect(db_params)
  end
  
  post "/clientes/:id/transacoes" do
    if /^\d+$/.match(params[:id])
      account = settings.db.exec_params('SELECT * FROM accounts WHERE id = $1', [params[:id]])[0]
  
      if !account.nil?
        account_id = account['id']
        query_params = normalize_params(params)

        if can_make_transaction?(account, query_params)
          balance = settings.db.exec_params('SELECT * FROM balances WHERE account_id = $1', [account['id']])[0]
          make_transaction(account_id, balance, query_params)
          { limite: account['limit_amount', saldo: balance['amount']] }.to_json
        else
          throw_new_error(422, 'Saldo insuficiente')
        end
      else
        throw_new_error(404, 'Conta não encontrada')
      end
    else
      throw_new_error(404, 'ID inválido')
    end
  end

  def can_make_transaction?(account, query_params)
    if query_params[:tipo] == 'd'
      (account['limit_amount'] >= query_params[:valor])
    else
      true
    end
  end

  def make_transaction(account_id, balance, query_params)
    settings.db.exec_params( 
      'INSERT INTO transactions (account_id, amount, kind, description) VALUES ($1, $2, $3, $4) RETURNING id, date_time',
      [account_id, query_params[:valor], query_params[:tipo], query_params[:descricao]])
    if query_params[:tipo] == 'd'
      new_amount_value = (balance['amount'].to_i - query_params[:valor])
      settings.db.exec_params( 
        'INSERT INTO balances (account_id, amount) VALUES ($1, $2) RETURNING id, amount',
        [account_id, new_amount_value])
    end
  end

  def throw_new_error(code, message)
    halt code, { 'Content-Type' => 'application/json' }, { error: message }.to_json
  end

  def normalize_params(params)
    query = {}
    query[:valor] = params[:valor].nil? ? params[:valor].to_i : nil
    query[:descricao] = params[:descricao]
    query[:tipo] = params[:tipo].nil? ? params[:tipo].downcase[0] : nil
    query
  end
end
