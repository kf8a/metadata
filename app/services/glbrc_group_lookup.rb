class GlbrcGroupLookup
  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    Array(user.last_glbrc_groups)
  end

  private

  attr_reader :user
end

