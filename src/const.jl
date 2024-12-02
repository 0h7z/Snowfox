# Copyright (C) 2022-2025 Heptazhou <zhou@0h7z.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

using Base: notnothing

const SRC = "src/"
const PKG = "pkg/"

# https://archive.mozilla.org/pub/firefox/
# https://whattrainisitnow.com
const ESR = v"128".major # 140
const VER = v"131.0.3-2"

const VER_REGEX = r"^v(?<ver>\d+\.\d+\.\d+)(?:-(?<rel>\d+))?(?:\+(?<pre>[a-z]+\d+))?$"
const VER_MATCH = notnothing(match(VER_REGEX, "v$VER"))
const VER_INFO  = let
	ver = VER_MATCH["ver"]
	rel = VER_MATCH["rel"]
	pre = VER_MATCH["pre"]
	alpha, beta, rc, moz_ver, moz_src, moz_tar, moz_url = let
		s = @something pre ""
		m = notnothing(match(r"^([a-z]+)?(\d+)?$", s))
		a, b, c = ("a", "b", "rc") .== m[1]
		u, v = m[2], replace(ver, r"(\.0)\K\1$" => "")
		w = v * (a | b ? s : "")
		x = "firefox-$v"
		y = "firefox-$w.source.tar.xz"
		z = "https://archive.mozilla.org/pub/firefox/" * (
		c ? "candidates/$w-candidates/build$u/" : "releases/$w/") * "source/$y"
		a, b, c, w, x, y, z
	end
	v = "$ver-$rel"
	(; v, alpha, beta, rc, moz_ver, moz_src, moz_tar, moz_url)
end

const TAR_PREFIX = "snowfox-v"
const TAR_SUFFIX = ".source.tar.zst"
const TAR_ZST_18 = "zstdmt -18 -M1024M --long"

const L10N_PKG_DIR = "l10n"
const L10N_PKG_TAR = "l10n.tar.zst"
const L10N_SRC_DIR = "firefox-l10n-main"
const L10N_SRC_TAR = "firefox-l10n-main.tar.gz"
const L10N_SRC_URL = "https://github.com/mozilla-l10n/firefox-l10n/archive/refs/heads/main.tar.gz"

const CURL      = @static Sys.iswindows() ? "wsl -- curl" : "curl"
const CURL_ARGS = let args = [
	"--fail-with-body"
	"--http2-prior-knowledge"
	"--tls" * "v1.3"
	"-A\"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:$ESR.0) Gecko/20100101 Firefox/$ESR.0\""
]
	join(args, " ")
end

# https://duckduckgo.com/favicon.ico
# https://github.com/Heptazhou/Firefox/blob/FIREFOX_NIGHTLY_128_END/browser/components/search/extensions/ddg/favicon.ico
# const icon_duck = "../Source/gecko/snowfox/policies.json"

# https://www.google.com/favicon.ico
# https://github.com/Heptazhou/Firefox/blob/FIREFOX_NIGHTLY_128_END/browser/components/search/extensions/google/favicon.ico
# const icon_goog = "../Source/gecko/snowfox/policies.json"

# https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/query-stripping/records
# https://github.com/brave/brave-core/blob/74ad0c0a/browser/net/brave_site_hacks_network_delegate_helper.cc
# https://github.com/brave/brave-core/blob/master/browser/net/brave_query_filter.cc
# https://github.com/DandelionSprout/adfilt/blob/master/LegitimateURLShortener.txt
# https://github.com/Heptazhou/Heptazhou.github.io/blob/master/URLenc/main.js
# https://github.com/the1812/Bilibili-Evolved/blob/master/registry/lib/components/utils/url-params-clean/index.ts
const strip_list_msc =
	[
		"__cft__[0]"
		"__sale_info__"
		"__tn__"
		"_at_"
		"_cldee"
		"_f"
		"_ff"
		"_nc_sid"
		"_rand"
		"_ts"
		"_wv"
		"ab_channel"
		"accept_quality"
		"ad_od"
		"adpicid"
		"adsVersion"
		"ADTAG"
		"amp"
		"app_version"
		"appshare"
		"appsongtype"
		"apptime"
		"appuid"
		"bbid"
		"bddid"
		"bdtype"
		"brand_redir"
		"broadcast_type"
		"bsft_clkid"
		"bsft_uid"
		"bsource"
		"buvid"
		"ckanonid"
		"client"
		"comefrom"
		"comment_on"
		"comment_root_id"
		"curator_clanid"
		"current_qn"
		"current_quality"
		"device_id"
		"device_type"
		"dm_progress"
		"dmid"
		"embeds_origin"
		"embeds_referring_origin"
		"embeds_widget_referrer"
		"enctid"
		"eqid"
		"esid"
		"euid"
		"euri"
		"fclid"
		"feature"
		"featurecode"
		"from_id"
		"from_idtype"
		"from_module"
		"from_name"
		"from_source"
		"from_spmid"
		"fromid"
		"fromtitle"
		"fromTitle"
		"fromurl"
		"game_version"
		"gbv"
		"group_id"
		"gsm"
		"hosteuin"
		"ig_cache_key"
		"inputT"
		"ipn"
		"is_reflow"
		"is_room_feed"
		"is_story_h5"
		"isappinstalled"
		"islist"
		"issp"
		"jid"
		"keywords"
		"lemmaIdFrom"
		"lfid"
		"live_from"
		"live_play_network"
		"lpsn"
		"luicode"
		"media_mid"
		"mktgSourceCode"
		"mpshare"
		"msource"
		"network_id"
		"network_status"
		"network"
		"newreg"
		"oid"
		"orgRef"
		"orig_msid"
		"oriquery"
		"p2p_type"
		"paipv"
		"pic_share_from"
		"pid"
		"plat_id"
		"platform_network_status"
		"platform"
		"playurl_h264"
		"playurl_h265"
		"prefixsug"
		"puid"
		"push_task_id"
		"qbl"
		"qid"
		"quality_description"
		"querylist"
		"rand"
		"rawFrom"
		"rdfrom"
		"recipientid"
		"refer_flag"
		"referfrom"
		"req_id"
		"retcode"
		"rnid"
		"rsf"
		"rsp"
		"rsv_bp"
		"rsv_btype"
		"rsv_cq"
		"rsv_dl"
		"rsv_enter"
		"rsv_idx"
		"rsv_iqid"
		"rsv_pq"
		"rsv_spt"
		"rsv_t"
		"sca_esv"
		"scene"
		"sclient"
		"sei"
		"seid"
		"session_id"
		"sfr"
		"sfrom"
		"share_from"
		"share_medium"
		"share_plat"
		"share_session_id"
		"share_source"
		"share_tag"
		"share_token"
		"share"
		"sharefrom"
		"sharer_shareid"
		"sharer_sharetime"
		"sid"
		"sigin"
		"simid"
		"sme"
		"source"
		"sourcecode"
		"sourceFrom"
		"sourceType"
		"spm_id_from"
		"spmref"
		"spn"
		"src_campaign"
		"src_medium"
		"src_source"
		"src_term"
		"src"
		"srcid"
		"ss_campaign_id"
		"ss_campaign_name"
		"ss_campaign_sent_date"
		"ss_email_id"
		"ss_source"
		"starNodeId"
		"suglabid"
		"suguuid"
		"tdsourcetag"
		"teclient"
		"timestamp"
		"treatmentID"
		"ts"
		"tt_from"
		"uct"
		"ufe"
		"uk"
		"unique_k"
		"up_id"
		"userCode"
		"usg"
		"usm"
		"usqp"
		"utm_ad"
		"utm_affiliate"
		"utm_brand"
		"utm_campaign"
		"utm_campaignid"
		"utm_channel"
		"utm_cid"
		"utm_content"
		"utm_emcid"
		"utm_emmid"
		"utm_id"
		"utm_keyword"
		"utm_medium"
		"utm_name"
		"utm_oi"
		"utm_place"
		"utm_product"
		"utm_pubreferrer"
		"utm_reader"
		"utm_referrer"
		"utm_relevant_index"
		"utm_serial"
		"utm_session"
		"utm_siteid"
		"utm_social-type"
		"utm_social"
		"utm_source"
		"utm_supplier"
		"utm_swu"
		"utm_term"
		"utm_umguk"
		"utm_user"
		"utm_userid"
		"utm_viz_id"
		"utrc"
		"vd_source"
		"ved"
		"visit_id"
		"weibo_id"
		"wfr"
		"wid"
		"wvr"
		"wxa_abtest"
		"wxfid"
		"wxshare_count"
		"xhsshare"
	]

# LegitimateURLShortener
const strip_list_ubo =
	[
		"__hsfp"
		"__hssc"
		"__hstc"
		"__s"
		"_hsenc"
		"_openstat"
		"dclid"
		"fbclid"
		"fromModule"
		"gbraid"
		"gclid"
		"gclsrc"
		"guccounter"
		"guce_referrer_sig"
		"guce_referrer"
		"hsCtaTracking"
		"igshid"
		"lemmaFrom"
		"lpn"
		"mc_cid"
		"mc_eid"
		"mkt_tok"
		"ml_subscriber_hash"
		"ml_subscriber"
		"msclkid"
		"oft_c"
		"oft_ck"
		"oft_d"
		"oft_id"
		"oft_ids"
		"oft_k"
		"oft_lk"
		"oft_sk"
		"oly_anon_id"
		"oly_enc_id"
		"rb_clickid"
		"ref_src"
		"ref_url"
		"refd"
		"s_cid"
		"scm_id"
		"scm-url"
		"scm"
		"spm"
		"src_content"
		"src_custom"
		"srsltid"
		"sudaref"
		"twclid"
		"vero_conv"
		"vero_id"
		"vgo_ee"
		"wbraid"
		"wickedid"
		"yclid"
		"ysclid"
	]

# Exemption
const strip_list_xpt =
	[
		"cid"  #* Azure DevOps Services
		"from" #* Zoom SSO
	]

const strip_list = String[strip_list_msc; strip_list_ubo]

