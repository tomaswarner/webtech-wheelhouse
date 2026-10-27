class AddTakenInByToRepairs < ActiveRecord::Migration[8.0]
  def change
    # NULL for the repairs taken in before there were accounts.
    add_reference :repairs, :taken_in_by, foreign_key: { to_table: :users }
  end
end
