# Description:
#   Forward Jira comments to Slack
# Dependencies:
#   None
# Configuration:
#   HUBOT_JIRA_URL
# Commands:
#   None
# Auther:
#   mnpk

module.exports = (robot) ->
  robot.router.post '/hubot/chat-jira-comment/:room', (req, res) ->
    room = req.params.room
    body = req.body

    if body.webhookEvent == 'jira:issue_updated'

      issue = "#{body.issue.key} #{body.issue.fields.summary}"
      url = "#{process.env.HUBOT_JIRA_URL}/browse/#{body.issue.key}"

      if body.comment
        robot.emit 'slack-attachment',
          channel: room
          content:
            mrkdwn_in: ['text']
            fallback: "#{issue}, Comment: #{body.comment.body}"
            color: "#91afb0"
            text: "<#{url}|#{issue}>\n*#{body.comment.author.displayName}:* <#{process.env.HUBOT_JIRA_URL}/secure/AddComment!default.jspa?id=#{body.issue.id}|Reply>\n```#{body.comment.body}```"

      if body.changelog
        for item in body.changelog.items
          if item.field is "status"
            robot.emit 'slack-attachment',
              channel: room
              content:
                mrkdwn_in: ['text']
                fallback: "#{issue}, Status: #{item.fromString} -> #{item.toString}"
                color: "#91afb0"
                text: "<#{url}|#{issue}>\n*Status Change*\n#{item.fromString} -> #{item.toString}"

    res.send 'OK'

