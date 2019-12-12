module AppModeConcern
  extend ActiveSupport::Concern

  VALID_MODES = [
    # Ramping up for election - announce we'll be participating and
    # drum up interest
    "closed-warm-up",

    # Open for swapping pre election
    "open",

    # Election day!
    # The old mode where we closed swaps:
    "closed-and-voting",
    # The fancy new mode where we keep swaps open but don't allow users
    # with confirmed swaps to cancel or change their voting preferences
    # or constituency.
    "open-and-voting",

    # Post-election aftermath
    "closed-wind-down"
  ]

  def valid_mode?(mode)
    VALID_MODES.include? mode
  end

  def app_mode
    env_mode = ENV["SWAPMYVOTE_MODE"].present? ? ENV["SWAPMYVOTE_MODE"] : "open"
    unless valid_mode?(env_mode)
      raise_invalid_mode("SWAPMYVOTE_MODE value", env_mode)
    end

    sesame_mode = session[:sesame]
    if sesame_mode.present? && !valid_mode?(sesame_mode)
      raise_invalid_mode("sesame", sesame_mode)
    end

    return sesame_mode.present? ? sesame_mode : env_mode
  end

  def raise_invalid_mode(type, mode)
    raise "Invalid #{type} '#{mode}'; should be one of: #{VALID_MODES}"
  end

  def swapping_open?
    return app_mode.include? "open"
  end

  def voting_open?
    return app_mode.include? "voting"
  end

  def voting_info_locked?
    voting_open? && current_user&.swap_confirmed?
  end
end
