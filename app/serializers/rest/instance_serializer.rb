# frozen_string_literal: true

class REST::InstanceSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :uri, :title, :short_description, :description, :email,
             :version, :urls, :stats, :thumbnail, :max_toot_chars, :poll_limits,
             :languages, :registrations, :approval_required, :invites_enabled,
             :local_only_posts

  has_one :contact_account, serializer: REST::AccountSerializer

  has_many :rules, serializer: REST::RuleSerializer

  delegate :contact_account, :rules, to: :instance_presenter

  def uri
    Rails.configuration.x.local_domain
  end

  def title
    Setting.site_title
  end

  def short_description
    Setting.site_short_description
  end

  def description
    Setting.site_description
  end

  def email
    Setting.site_contact_email
  end

  def version
    Mastodon::Version.to_s
  end

  def thumbnail
    instance_presenter.thumbnail ? full_asset_url(instance_presenter.thumbnail.file.url) : full_pack_url('media/images/preview.jpg')
  end

  def max_toot_chars
    StatusLengthValidator::MAX_CHARS
  end

  def poll_limits
    {
      max_options: PollValidator::MAX_OPTIONS,
      max_option_chars: PollValidator::MAX_OPTION_CHARS,
      min_expiration: PollValidator::MIN_EXPIRATION,
      max_expiration: PollValidator::MAX_EXPIRATION,
    }
  end

  def stats
    {
      user_count: instance_presenter.user_count,
      status_count: instance_presenter.status_count,
      domain_count: instance_presenter.domain_count,
    }
  end

  def urls
    { streaming_api: Rails.configuration.x.streaming_api_base_url }
  end

  def languages
    [I18n.default_locale]
  end

  def registrations
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end

  def approval_required
    Setting.registrations_mode == 'approved'
  end

  def invites_enabled
    Setting.min_invite_role == 'user'
  end

  def local_only_posts
    true
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
