# frozen_string_literal: true

class CreateActiveStorageVariantRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :active_storage_variant_records do |t|
      t.belongs_to :blob, null: false, index: false
      t.string :variation_digest, null: false
    end

    add_index :active_storage_variant_records, [ :blob_id, :variation_digest ],
              name: "index_active_storage_variant_records_uniqueness", unique: true
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
end
