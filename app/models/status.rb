# == Schema Information
# Schema version: 20081126211147
#
# Table name: statuses
#
#  id                    :integer(4)      not null, primary key
#  created_at            :datetime
#  profile_image_url     :string(255)
#  from_user             :string(255)
#  to_user_id            :integer(4)
#  text                  :string(255)
#  status_id             :integer(4)
#  from_user_id          :integer(4)
#  to_user               :string(255)
#  iso_language_code     :string(255)
#  in_reply_to_status_id :integer(4)
#  type                  :string(255)
#

class Status < ActiveRecord::Base
end
