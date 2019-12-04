class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:oktaoauth]

  has_many :issues
  has_many :resolved_issues, class_name: "Issue"
  has_many :batches
  has_many :activity_logs
end
