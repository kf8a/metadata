unless Factory.factories.include?(:user) #prevent redefining these factories

  Factory.sequence :email do |n|
    "user#{n}@example.com"
  end

  Factory.define :user do |user|
    user.email                 { Factory.next :email }
    user.password              { "password" }
    user.password_confirmation { "password" }
  end

  Factory.define :email_confirmed_user, :parent => :user do |user|
    user.email_confirmed { true }
  end

  Factory.define :admin_user, :parent => :email_confirmed_user do |user|
    user.role {'admin'}
  end

end