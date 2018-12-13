class CreateNewspaperWorksDerivativeAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :newspaper_works_derivative_attachments do |t|

      t.timestamps
    end
  end
end
