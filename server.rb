# -*- coding: utf-8 -*-
require 'webrick'
require 'byebug'

# リソースのクラス定義
class Product
  attr_accessor :name, :price, :stock

  def initialize(attrs)
    attrs.each { |attr, value| instance_variable_set("@#{attr}", value) }
  end
end

class ProductList < Array
end

# 初期データの設定
list = ProductList.new
list << Product.new(name: 'ぺんぎんのぬいぐるみ', price: 2900, stock: 1)
list << Product.new(name: '食ぱんクッション', price: 5600, stock: 21)

# Webickのサーバ設定と起動
server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/products') do |_req, res|
  res.body = list.map(&:inspect).join("\n")
end

server.mount_proc('/product') do |req, res|
  req.query.each { |key, value| req.query[key] = value.force_encoding('utf-8') }
  q = req.query
  new_product = Product.new(
    name: q['name'],
    price: q['price'].to_i,
    stock: q['stock'].to_i
  )
  list << new_product
  res.body = new_product.inspect
end

trap(:INT) { server.shutdown }
server.start
