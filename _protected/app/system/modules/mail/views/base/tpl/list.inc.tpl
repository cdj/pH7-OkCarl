{@if(empty($error))@}

<form method="post" action="{{ $design->url('mail','main','inbox') }}">
{{ $designSecurity->inputToken('mail_action') }}

<p><input type="checkbox" name="all_action" /></p>

<div class="mb_nav">
 <div class="user">{@lang('Author')@}</div> <div class="subject">{@lang('Subject')@}</div> <div class="message">{@lang('Message')@}</div> <div class="date">{@lang('Date')@}</div> <div class="action">{@lang('Action')@}</div>
</div>

{* Set Variables *}
{{ $is_admin = (AdminCore::auth() && !UserCore::auth()) }}
{{ $ctrl = ($is_admin) ? 'admin' : 'main' }}

{@if($is_admin)@}<div class="divShow">{@/if@}

{@foreach($msgs as $msg)@}

  {* Set Variables *}
  {{ $usernameSender = (empty($msg->username)) ? 'admin' : $msg->username }}
  {{ $firstNameSender = (empty($msg->firstName)) ? 'admin' : $msg->firstName }}
  {{ $subject = escape(substr(Framework\Security\Ban\Ban::filterWord($msg->title, false),0,20), true) }}
  {{ $message = escape(Framework\Security\Ban\Ban::filterWord($msg->message), true) }}
  {{ $is_outbox = ($msg->sender == $member_id) }}
  {{ $is_trash = (($msg->sender == $member_id && $msg->trash == 'sender') || ($msg->recipient == $member_id && $msg->trash == 'recipient') && !is_outbox && !$is_admin) }}
  {{ $slug_url = ($is_trash ? 'trash' : ($is_outbox ? 'outbox' : 'inbox')) }}
  {{ $is_delete = ($is_outbox || $is_trash || $is_admin) }}
  {{ $move_to = ($is_delete) ? 'delete' : 'trash' }}
  {{ $label_txt = ($is_delete) ? t('Delete') : t('Trash') }}

  <div class="msg_content" id="mail_{% $msg->messageId %}">
  <div class="left"><input type="checkbox" name="action[]" value="{% $msg->messageId %}" /></div>
  {@if($msg->status == 1)@}<img src="{url_tpl_img}icon/new.gif" alt="{@lang('New Message')@}" title="{@lang('Unread')@}" />{@/if@}
  <div class="user">{{ $avatarDesign->get($usernameSender, $firstNameSender, null, 32) }}</div>

  {@if($is_admin)@}
    <div class="content" title="{@lang('See more')@}"><a href="#divShow_{% $msg->messageId %}">
  {@else@}
    <div class="content" title="{@lang('See more')@}" onclick="window.location='{{ $design->url('mail','main',$slug_url,$msg->messageId) }}'">
  {@/if@}

  <div class="subject">{subject}</div>
  <div class="message">{% substr($message,0,50) %}</div>
  </div>
  <div class="date">{% $dateTime->get($msg->sendDate)->dateTime() %}</div>
  <div class="action"><a href="{{ $design->url('mail','main','compose',"$usernameSender,$subject") }}">{@lang('Reply')@}</a> | <a href="javascript:void(0)" onclick="mail('{move_to}',{% $msg->messageId %},'{csrf_token}')">{label_txt}</a>
  {@if($is_trash)@} | <a href="javascript:void(0)" onclick="mail('restor',{% $msg->messageId %},'{csrf_token}')">{@lang('Restor')@}</a>{@/if@}</div>

  {@if($is_admin)@}
    {* The hidden message *}
    <div class="hidden center" id="divShow_{% $msg->messageId %}">{message}</div>
  {@/if@}
</div>

{@/foreach@}
{@if($is_admin)@}</div>{@/if@}

<p><input type="checkbox" name="all_action" /> <button type="submit" onclick="return checkChecked()" formaction="{{ $design->url('mail',$ctrl,'set'.$move_to.'all') }}">{label_txt}</button>
{@if($is_trash)@} | <button type="submit" onclick="return checkChecked(false)" formaction="{{ $design->url('mail',$ctrl,'setrestorall') }}">{@lang('Move to Inbox')@}</button>{@/if@}</p>

</form>

{@main_include('page_nav.inc.tpl')@}

{@else@}

<p class="center bold">{error}</p>

{@/if@}
