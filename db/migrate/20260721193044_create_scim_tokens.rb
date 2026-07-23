# frozen_string_literal: true

class CreateScimTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :scim_tokens do |t|
      t.references :company, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.string :name
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :scim_tokens, :token_digest, unique: true
  end
end
