class AddRoleAndStaffMemberToUsers < ActiveRecord::Migration[8.0]
  def change
    # counter is the role with the fewest permissions (docs/decisions.md, "The role of a new account").
    add_column :users, :role, :string, null: false, default: "counter"

    # At most one account per member of the staff; an account may have none.
    add_reference :users, :staff_member, foreign_key: true, index: { unique: true }

    # The generator's index compares the stored text. This one refuses
    # Ana@Wheelhouse.cl next to ana@wheelhouse.cl even if a row skips the model.
    remove_index :users, :email_address, unique: true
    add_index :users, "lower(email_address)", unique: true, name: "index_users_on_lower_email_address"
  end
end
