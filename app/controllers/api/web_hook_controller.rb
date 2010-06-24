class Api::WebHookController < ApplicationController
  def receive_hook
    case params[:integration_type]
      when 'pivotal'
        if params.has_key? 'activity'
          process_pivotal_activity(params['activity'])
        elsif params.has_key? 'activities'
          params['activities'].each do |key, value|
            if key == 'activity'
              process_pivotal_activity(value)
            end
          end
        end
    end
    render :nothing => true
  end

#  protected

    def process_pivotal_activity(activity)
      event = Hash.new
      activity.each do |key, value|
        case key
          when 'event_type'
            event['type'] = value
          when 'occurred_at'
            event['time'] = Time.zone.parse(value)
          when 'author'
            by_nick = User.active.find_by_nickname(value)
            if by_nick.instance_of? User
              event['actor'] = by_nick
            end
          when 'project_id'
            project = Project.find_by_source_id(value.to_i)
            if project.instance_of? Project
              event['project'] = project
            end
          when 'stories'
            event['stories'] = Array.new
            value.each do |story|
              if story.name == 'story'
                local_story = Hash.new
                story.each do |story_element_key, story_element|
                  case story_element_key
                    when 'id'
                      local_story['source_id'] = story_element
                    when 'other_id'
                      local_story['id'] = story_element.to_i
                    when 'url'
                      local_story['source_url'] = story_element
                    when 'name'
                      local_story['title'] = story_element
                    when 'description'
                      local_story['description'] = story_element
                    when 'story_type'
                      local_story['story_type'] = story_element
                    when 'owned_by'
                      if !story_element.blank?
                        user = User.find_by_nickname(story_element)
                        local_story['assignee'] = user unless user.nil?
                      end
                    when 'requested_by'
                      if !story_element.blank?
                        user = User.find_by_nickname(story_element)
                        local_story['owner'] = user unless user.nil?
                      end
                    when 'current_state'
                      local_story['status'] = story_element
                    when 'accepted_at'
                      local_story['accepted_at'] = Time.zone.parse(story_element)
                    when 'notes'
                      local_story['notes'] = Array.new
                      story_element.each do |note_key, note|
                        if note_key == 'note'
                          local_note = Hash.new
                          note.each do |note_element_key, note_element|
                            case note_element_key
                              when 'text'
                                local_note['body'] = note_element unless note_element.empty?
                              when 'id'
                                local_note['story_source'] = 'pivotal'
                                local_note['source_id'] = note_element
                            end
                          end
                          local_story['notes'] << local_note
                        end
                      end
                  end
                end
                event['stories'] << local_story
              end
            end
          when 'destination_project'
            activity.each do |project_data_key, project_data|
              if project_data_key == 'id'
                event['new_project'] = Project.find_by_source_id(project_data)
              end
            end
          when 'source_project'
            activity.each do |project_data_key, project_data|
              if project_data_key == 'id'
                event['old_project'] = Project.find_by_source_id(project_data)
              end
            end
        end
      end

      case event['type']
        when 'story_create', 'story_update', 'note_create'
          unless event['project'].nil?
            event['stories'].each do |pivotal_story|
              if event['type'] == 'note_create'
                notes = pivotal_story.delete 'notes'
              end
              story = get_or_create_story('pivotal', pivotal_story)
              if story.new_record?
                story.project = event['project']
                if event['type'] == 'story_create'
                  story.owner = event['actor'] if event.has_key? 'actor'
                else
                  pivotal_story_id = pivotal_story['source_id']
                  pivotal_project = event['project'].get_source_project
                  pivotal_story = populate_story_hash_from_pivotal_story(pivotal_story, pivotal_project, pivotal_story_id)
                end
              end
              unless story.project.nil? || (event['project'].instance_of?(Project) && story.project != event['project'])
                if story.new_record? || story.updated_at.nil? || event['time'] > story.updated_at
                  synchronize_attributes(pivotal_story, story)
                  story.save
                end
              end
              if event['type'] == 'note_create'
                notes.each do |note|
                  story.notes.create(:body => note['body'], :story_source => note['story_source'], :source_id => note['source_id'], :author => event['actor'])
                end
              end
            end
          end
        when 'story_delete'
        when 'move_into_project', 'move_from_project'
          unless !event['project'].instance_of?(Project) && !event['new_project'].instance_of?(Project)
            new_project = nil
            if event['type'] == 'move_into_project'
              new_project = event['new_project'] if event['new_project'].instance_of?(Project)
            else
              new_project = event['project'] if !event['project'].instance_of?(Project)
            end
            event['stories'].each do |pivotal_story|
              story = get_or_create_story('pivotal', pivotal_story)
              unless new_project.nil?
                if story.new_record?
                  story.project = event['project']
                  pivotal_story_id = pivotal_story['source_id']
                  pivotal_project = event['project'].get_source_project
                  pivotal_story = populate_story_hash_from_pivotal_story(pivotal_story, pivotal_project, pivotal_story_id)
                end
                story.project = new_project
                unless story.project.nil? || (event['project'].instance_of?(Project) && story.project != event['project'])
                  if story.new_record? || story.updated_at.nil? || event['time'] > story.updated_at
                    synchronize_attributes(pivotal_story, story)
                    story.save
                  end
                end
              else
                if story.new_record?
                  story.destroy
                else
                  story.project = nil
                  story.save
                end
              end
            end
          end
      end
    end

    def get_or_create_story(story_source, story_hash)
      internal_id = nil
      source_id = nil
      story = nil
      case story_source
        when 'pivotal'
          if story_hash.has_key?('id') && !story_hash['id'].nil? && !story_hash['id'].blank? && story_hash['id'] > 0
            internal_id = story_hash['id']
          end
          if story_hash.has_key? 'source_id'
            source_id = story_hash['source_id']
          end
      end
      unless internal_id.nil?
        begin
          story = Story.find(internal_id)
        rescue ActiveRecord::RecordNotFound
        end
      end
      if story.nil?
        unless story_source.nil? || source_id.nil?
          story = Story.find_by_source_id(source_id, :conditions => {:story_source => story_source})
        end
      end
      if story.nil?
        story = Story.new(:story_source => story_source, :source_id => source_id)
      end
      return story
    end

    def populate_story_hash_from_pivotal_story(story_hash, pivotal_project, pivotal_story_id)
      full_pivotal_story = pivotal_project.stories.find(pivotal_story_id)
      story_hash['title'] = full_pivotal_story.name
      story_hash['description'] = full_pivotal_story.description
      story_hash['owner'] = User.find_by_nickname(full_pivotal_story.requested_by)
      story_hash['assignee'] = User.find_by_nickname(full_pivotal_story.owned_by)
      story_hash['status'] = full_pivotal_story.current_state
      story_hash['story_type'] = full_pivotal_story.story_type
      return story_hash
    end

    def synchronize_attributes(attribute_hash, story)
      unless story.nil? || attribute_hash.nil?
        attribute_hash.each do |attribute, value|
          if story.respond_to?("#{attribute}=")
            story.send("#{attribute}=", value) if story.send(attribute) != value
          end
        end
      end
    end
end
