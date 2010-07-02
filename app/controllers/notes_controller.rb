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
          note_header = "*#{current_user.fullname} said:*\n"
        else
          note_header = "*#{current_user.fullname} talked about \"#{note.subject}\":*\n"
        end
        pivotal_story.notes.create(:text => note_header + note.body)
      rescue
        flash.now[:error] = 'Unable to create note, please try again. If this continues, please contact your administrator.'
        @story = story
        @note = note
        render 'stories/show'
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
