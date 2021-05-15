SELECT
	content.Id game_id,
	content_ability.AbilityTypeName ab_type,
	content_ability.FirstAbilityName ab_name_first,
	content_ability.SecondAbilityName ab_name_second
FROM
	iquizoo_content_db.content
	INNER JOIN iquizoo_content_db.content_ability ON content.Id = content_ability.ContentId;
