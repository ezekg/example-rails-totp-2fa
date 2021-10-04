class AddOtpVerifiedAtToSecondFactors < ActiveRecord::Migration[6.1]
  def change
    add_column :second_factors, :otp_verified_at, :datetime, null: true
  end
end
