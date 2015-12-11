cription:
#   Forward Jira comments to Slack.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JIRA_URL
#
# Commands:
#   None
#
# Author:
#   mnpk <mnncat@gmail.com>
#
# Replaced with https://gist.github.com/scott2449/e22c8d07951f59354052

statuscolor = '2fa4e7'
commentcolor = '91afb0'

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
            text: "<#{url}|#{issue}>\n*#{body.comment.author.displayName}:* <#{process.env.HUBOT_JIRA_URL}/secure/AddComment!default.jspa?id=#{body.issue.id}|Reply>\n```#{body.comment.body}```"
            color: commentcolor

      if body.changelog
        for item in body.changelog.items
          if item.field is "status"
            robot.emit 'slack-attachment',
              channel: room
              content:
                mrkdwn_in: ['text']
                fallback: "#{issue}, Status: #{item.fromString} -> #{item.toString}"
                text: "<#{url}|#{issue}>\n*Status Change*\n#{item.fromString} -> #{item.toString}"
                color: commentcolor

    res.send 'OK'

