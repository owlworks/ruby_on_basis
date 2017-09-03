# -*- coding: utf-8 -*-
require 'webrick'
require 'byebug'

# リソースのクラス定義
class Product
  @@id_num = 0
  attr_accessor :name, :price, :stock

  def initialize(attrs)
    @@id_num += 1
    @id = @@id_num
    attrs.each { |attr, value| instance_variable_set("@#{attr}", value) }
  end
end

class Controller
  def initialize
    @products = []
    @products << Product.new(name: 'ぺんぎんのぬいぐるみ', price: 2900, stock: 1)
    @products << Product.new(name: '食ぱんクッション', price: 5600, stock: 21)
  end

  def get_products(request)
    @products.map(&:inspect).join("\n")
  end

  def post_product(request)
    q = request.query
    new_product = Product.new(
      name: q['name'],
      price: q['price'].to_i,
      stock: q['stock'].to_i
    )
    @products << new_product
    new_product.inspect
  end
end

# リクエストのデータを処理してレスポンスを作成する
controller = Controller.new

# Webickのサーバ設定と起動
server = WEBrick::HTTPServer.new(Port: 3000)

RESOURCES = ['products', 'product']

RESOURCES.each do |resource|
  server.mount_proc("/#{resource}") do |req, res|
    req.query.each { |key, value| req.query[key] = value.force_encoding('utf-8') }
    method_name = "#{req.request_method.downcase}_#{resource}"
    res.body = controller.send(method_name.to_sym, req)
  end
end

trap(:INT) { server.shutdown }
server.start
