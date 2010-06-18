class Api::WebHookController < ApplicationController
  def receive_hook
    case params[:integration_type]
      when 'pivotal'
        hook = XML::Document.string(params[:body].lstrip)
        process_pivotal_hook(hook)
    end
    render :nothing => true
  end

#  protected

    def process_pivotal_hook(hook_body_doc)
      case hook_body_doc.root.name
        when 'activity'
          process_pivotal_activity(hook_body_doc.root)
        when 'activities'
          hook_body_doc.root.children.each do |activity|
            process_pivotal_activity(activity)
          end
      end
    end

    def process_pivotal_activity(activity)
      event = Hash.new
      if activity.name == 'activity' && activity.children?
        activity.children.each do |child|
          case child.name
            when 'event_type'
              event['type'] = child.content
            when 'occurred_at'
              event['time'] = Time.zone.parse(child.content)
            when 'author'
              by_nick = User.active.find_by_nickname(child.content)
              if by_nick.instance_of? User
                event['actor'] = by_nick
              end
            when 'project_id'
              project = Project.find_by_source_id(child.content.to_i)
              if project.instance_of? Project
                event['project'] = project
              end
            when 'stories'
              event['stories'] = Array.new
              child.children.each do |story|
                if story.name == 'story'
                  local_story = Hash.new
                  story.children.each do |story_element|
                    case story_element.name
                      when 'id'
                        local_story['source_id'] = story_element.content.to_i
                      when 'other_id'
                        local_story['id'] = story_element.content.to_i
                      when 'url'
                        local_story['source_url'] = story_element.content
                      when 'name'
                        local_story['title'] = story_element.content
                      when 'description'
                        local_story['description'] = story_element.content
                      when 'story_type'
                        local_story['story_type'] = story_element.content
                      when 'owned_by'
                        if !story_element.content.blank?
                          user = User.find_by_nickname(story_element.content.to_s)
                          local_story['assignee'] = user unless user.nil?
                        end
                      when 'requested_by'
                        if !story_element.content.blank?
                          user = User.find_by_nickname(story_element.content.to_s)
                          local_story['owner'] = user unless user.nil?
                        end
                      when 'current_state'
                        local_story['status'] = story_element.content
                      when 'accepted_at'
                        local_story['accepted_at'] = Time.zone.parse(story_element.content)
                      when 'notes'
                        local_story['notes'] = Array.new
                        story_element.children.each do |note|
                          if note.name == 'note'
                            local_note = Hash.new
                            note.children.each do |note_element|
                              case note_element.name
                                when 'text'
                                  local_note['body'] = note_element.content unless note_element.empty?
                                when 'id'
                                  local_note['story_source'] = 'pivotal'
                                  local_note['source_id'] = note_element.content.to_i
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
              child.children.each do |project_data|
                if project_data.name == 'id'
                  event['new_project'] = Project.find_by_source_id(project_data.content.to_i)
                end
              end
            when 'source_project'
              child.children.each do |project_data|
                if project_data.name == 'id'
                  event['old_project'] = Project.find_by_source_id(project_data.content.to_i)
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
