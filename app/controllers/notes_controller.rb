class NotesController < ApplicationController
  def create
    note = Note.new(params[:note])
    story = Story.find(params[:story_id])
    note.story = story
    note.author = current_user
    unless story.story_source.nil? || story.story_source != 'pivotal'
      begin
        pivotal_project = story.project.get_source_project
        pivotal_story = pivotal_project.stories.find(story.source_id)
        if note.subject.empty?
          note_header = "*#{current_user.fullname} said:*\n\n"
        else
          note_header = "**#{current_user.fullname} talked about \"#{note.subject}\":**\n\n"
        end
        pivotal_story.notes.create(:text => note_header + note.body)
        flash[:success] = 'Note posted sucessfully; please wait a few moments before refreshing if you don\'t see it.'
      rescue => e
        error_message = 'Unable to create note, please try again. If this continues, please contact your administrator.<br>'
        backtrace = String.new
        e.backtrace.each do |msg|
          backtrace += "#{msg}\n"
        end
        logger.error backtrace
        if e.respond_to? 'response'
          if e.response.nil?
            error_message += "#{e.class} exception#{e.respond_to?('message') ? ':' + e.message : '.'}"
          else
            error_message += "Remote source exception: #{e.response}"
          end
        else
          error_message += "#{e.class} exception#{e.respond_to?('message') ? ':' + e.message : '.'}"
        end
        flash.now[:error] = error_message
        @story = story
        @note = note
        render 'stories/show' and return
      end
    else
      note.save
    end
    redirect_to story_url(story)
  end

  def edit
  end

  def update
  end

end
