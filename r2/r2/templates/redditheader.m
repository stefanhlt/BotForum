## The contents of this file are subject to the Common Public Attribution
## License Version 1.0. (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License at
## http://code.reddit.com/LICENSE. The License is based on the Mozilla Public
## License Version 1.1, but Sections 14 and 15 have been added to cover use of
## software over a computer network and provide for limited attribution for the
## Original Developer. In addition, Exhibit A has been modified to be
## consistent with Exhibit B.
##
## Software distributed under the License is distributed on an "AS IS" basis,
## WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
## the specific language governing rights and limitations under the License.
##
## The Original Code is reddit.
##
## The Original Developer is the Initial Developer.  The Initial Developer of
## the Original Code is reddit Inc.
##
## All portions of the code written by reddit are Copyright (c) 2006-2015
## reddit Inc. All Rights Reserved.
###############################################################################

<%!
   from pylons import request
   from r2.config import feature
   from r2.lib.template_helpers import (
       add_sr,
       display_link_karma,
       format_number,
       header_url,
   )
   from r2.models import FakeSubreddit
   from r2.models.subreddit import DefaultSR
   from r2.lib.pages import SearchForm
%>
<%namespace file="utils.m" import="plain_link, img_link, text_with_links, separator, logout"/>

<div id="header" role="banner">
  <a tabindex="1" href="#content" id="jumpToContent">${_('jump to content')}</a>
  ${thing.srtopbar}
  <div id="header-bottom-left">
    <%
        header_title = c.site.header_title
        d = thing.default_theme_sr

        if c.site.header and c.can_apply_styles and c.allow_styles and not (thing.no_sr_styles or c.site.quarantine):
            header_img = c.site.header
            header_size = c.site.header_size
        else:
            header_img = d.header
            header_size = d.header_size
            header_title = d.header_title
    %>
    
    % if header_img != g.default_header_url:
        ${img_link(c.site.name, header_url(header_img),
            '/', _id="header-img-a", img_id='header-img',
            title=header_title, size=header_size)}
    % else:
        <a href="/" id="header-img" class="default-header">${g.domain}</a>
    % endif
    
    ##keeps the height of the header from varying when there isnt any content
    &nbsp;

    %for toolbar in thing.toolbars:
      ${toolbar}
    %endfor
  </div>

  </div>

  <div id="header-bottom-right">
    %if not c.user_is_loggedin:
      %if thing.enable_login_cover and not g.read_only_mode:
      <span class="user">
        <%
          base = g.https_endpoint
          login_url = add_sr(base + "/login", sr_path=False)
        %>
        ${text_with_links(_("Want to join? %(login_or_register)s in seconds."),
            login_or_register = dict(link_text=_("Log in or sign up"), path=login_url, _class="login-required"))}
      </span>
      ${separator("|")}
      %endif
    %else:
      %if feature.is_enabled('beta_opt_in') and c.user.pref_beta:
        <div class="beta-hint help help-hoverable">
          <a class="beta-link" href="/${g.brander_community_abbr}/${g.beta_sr}">beta</a>
          <div id="beta-help" class="hover-bubble help-bubble anchor-top">
            <div class="help-section">
              <p>${_("You're in beta mode! Thanks for helping to test reddit.")}</p>
              <p>
              ${text_with_links(_("Please give feedback at %(beta_link)s, or %(learn_more_link)s."),
                  beta_link = dict(link_text="/" + g.brander_community_abbr + "/" + g.beta_sr, path="/" + g.brander_community_abbr + "/" + g.beta_sr),
                  learn_more_link = dict(link_text=_("learn more on the wiki"), path="/" + g.brander_community_abbr + "/" + g.beta_sr + "/wiki")
                )}
              </p>
            </div>
          </div>
        </div>
      %endif
      <span class="user">
         ${plain_link(c.user.name, "/user/%s/" % c.user.name, _sr_path=False)}
         &nbsp;(<span class="userkarma" title="${_("post karma")}">${format_number(display_link_karma(c.user.link_karma))}</span>)
      </span>

      ${separator("|")}


      %if c.have_messages:
        ${plain_link(_("messages"), path="/message/unread/", title=_("new mail!"), _class="havemail", _sr_path=False, _id="mail")}
        %if c.user.inbox_count > 0:
          ${plain_link(c.user.inbox_count, path="/message/unread/", _class="message-count", _sr_path=False)}
        %endif
      %else:
        ${plain_link(_("messages"), path="/message/inbox/", title=_("no new mail"), _class="nohavemail", _sr_path=False, _id="mail")}
      %endif
      ${separator("|")}
      %if c.user_is_loggedin and c.user.is_moderator_somewhere:
         <%
            if c.have_mod_messages:
              mail_img_class = 'havemail'
              mail_img_title = "new mod mail!"
              mail_path = "/message/moderator/"
            else:
              mail_img_class = 'nohavemail'
              mail_img_title = "no new mod mail"
              mail_path = "/message/moderator/"
            
            css_class = "%s access-required" % mail_img_class
            data_attrs = {'event-action': 'pageview', 'event-detail': 'modmail'}
          %>
         ${plain_link(_("mod messages"), path=mail_path,
                    title = mail_img_title, _sr_path = False,
                    _id = "modmail", _class=css_class, data=data_attrs)}
         ${separator("|")}
      %endif
    %endif
    ${thing.corner_buttons()}
    %if c.user_is_loggedin and g.auth_provider.is_logout_allowed():
      ${separator("|")}
      ${logout(dest=request.fullpath)}
    %endif
  </div>

