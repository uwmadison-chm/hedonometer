class Admin::JobsController < AdminController
  def index
    @job_stats = {
      :failed => failed.count,
      :in_process => in_process.count,
      :queued => queued.count,
      :retrying => retrying.count,
    }
  end

  def view
    @kind = params[:kind]
    case @kind
    when "failed"
      @jobs = failed.all
    when "in_process"
      @jobs = in_process.all
    when "queued"
      @jobs = queued.all
    when "retrying"
      @jobs = retrying.all
    end
  end

  def failed
    Delayed::Job.where('failed_at IS NOT NULL')
  end

  def in_process
    Delayed::Job.where('failed_at IS NULL').where('locked_at > ?', Time.now - Delayed::Worker.max_run_time)
  end

  def retrying
    Delayed::Job.where('failed_at IS NULL').where('attempts > 0')
  end

  def queued
    Delayed::Job.where('failed_at IS NULL').where('attempts = 0').where('run_at <= ?', Time.now)
  end

end

