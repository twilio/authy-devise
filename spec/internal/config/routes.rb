# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  devise_for :lockable_users, class: 'LockableUser' # for testing authy_lockable
end
