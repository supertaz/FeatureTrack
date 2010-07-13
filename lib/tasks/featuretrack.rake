namespace :featuretrack do
  task :migrate_defects_to_stories => :environment do
    Defect.all.each do |defect|
      new_story = Story.new
      puts "Migrate defect #{defect.id}: #{defect.title}\n"
      unless defect.story_source.nil?
        if defect.story_source == 'pivotal' && !defect.story_id.nil?
          story = Story.find_by_source_id(defect.story_id)
          unless story.nil?
            new_story = story
          end
          new_story.story_source = 'pivotal'
          new_story.source_id = defect.story_id
          begin
            new_story.source_url ||= defect.get_story_url
          rescue
          end
        end
      end
      new_story.story_type = 'bug'
      new_story.requestor ||= defect.reporter
      new_story.owner ||= defect.owner
      new_story.environment ||= defect.environment
      new_story.affected ||= defect.affected
      new_story.severity ||= defect.severity
      new_story.priority ||= defect.priority
      new_story.title ||= defect.title
      new_story.description ||= defect.description
      new_story.execution_priority ||= defect.execution_priority
      new_story.status ||= defect.status
      new_story.risk ||= defect.risk
      new_story.functional_area ||= defect.functional_area
      new_story.project ||= defect.project
      new_story.created_at = defect.created_at unless new_story.new_record? || defect.created_at > new_story.created_at
      new_story.save
    end
  end

  task :migrate_feature_requests_to_stories => :environment do
    FeatureRequest.all.each do |req|
      new_story = Story.new
      puts "Migrate request #{req.id}: #{req.title}\n"
      unless req.story_source.nil?
        if req.story_source == 'pivotal' && !req.story_id.nil?
          story = Story.find_by_source_id(req.story_id)
          unless story.nil?
            new_story = story
          end
          new_story.story_source = 'pivotal'
          new_story.source_id = req.story_id
        end
      end
      new_story.story_type = 'feature'
      new_story.requestor ||= req.requestor
      new_story.affected ||= req.affected
      new_story.priority ||= req.priority
      new_story.title ||= req.title
      new_story.description ||= req.description
      new_story.status ||= req.status
      new_story.risk ||= req.risk
      new_story.functional_area ||= req.functional_area
      new_story.project ||= req.project
      new_story.created_at = req.created_at unless new_story.new_record? || req.created_at > new_story.created_at
      new_story.save
    end
  end

  desc 'Make everything a story'
  task :migrate_all_to_stories => [:migrate_defects_to_stories, :migrate_feature_requests_to_stories]

  desc 'Migrate defect story linkages' => :environment do
    Story.bugs.each do |defect|
      if defect.against_story_source.nil? && !defect.against_story_id.nil?
        story = Story.try(:find_by_source_id, defect.against_story_id)
        unless story.nil?
          defect.against_story_source = 'internal'
          defect.against_story_id = story.id
          defect.save
        else
          story = Story.try(:find, defect.against_story_id)
          unless story.nil?
            defect.against_story_source = 'internal'
            defect.save
          else
            if !defect.story_source.nil?
              defect.against_story_source = defect.story_source
              defect.save
            else
              defect.against_story_source = 'internal'
              defect.save
            end
          end
        end
      end
    end
  end
end
