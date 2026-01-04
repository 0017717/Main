// ==UserScript==
// @name         Tiện ích Hanami Nikata
// @namespace    hanami-nikata-helper
// @version      2.0.3
// @description  Tiện ích Hanami Nikata.
// @author       Hanami Nikata & Gemini
// @match        *://*.ugphone.com/toc-portal/*
// @match        *://*.cloudemulator.net/*
// @match        *://*.cccloudphone.com/*
// @match        *://*.vmoscloud.com/*
// @match        *://*.vsphone.com/*
// @match        *://vuotlink.nikata.fun/*
// @grant        GM.setValue
// @grant        GM.getValue
// @grant        GM.deleteValue
// @grant        GM.listValues
// @grant        GM.info
// @run-at       document-start
// @icon         https://i.postimg.cc/Rhv19Fgs/icon128.png
// ==/UserScript==

(function(){'use strict';window.HanamiBridge={setValue:async(k,v)=>await GM.setValue(k,v),getValue:async(k,d)=>await GM.getValue(k,d),deleteValue:async(k)=>await GM.deleteValue(k),listValues:async()=>await GM.listValues(),info:GM.info};async function setStorage(k,v){try{if(window.HanamiBridge?.setValue)await HanamiBridge.setValue(k,v);}catch(e){console.warn(`[Hanami Helper] Lỗi khi lưu vào Hanami Bridge: ${e.message}`);}try{localStorage.setItem(k,v);}catch(e){console.warn(`[Hanami Helper] Lỗi khi lưu vào localStorage: ${e.message}`);}}async function getStorage(k,d=null){try{if(window.HanamiBridge?.getValue){const v=await HanamiBridge.getValue(k,null);if(v!==null&&typeof v!=='undefined')return v;}}catch(e){console.warn(`[Hanami Helper] Lỗi khi lấy từ Hanami Bridge: ${e.message}`);}const lv=localStorage.getItem(k);return lv!==null?lv:d;}async function removeStorage(k){try{if(window.HanamiBridge?.deleteValue)await HanamiBridge.deleteValue(k);}catch(e){console.warn(`[Hanami Helper] Lỗi khi xóa khỏi Hanami Bridge: ${e.message}`);}try{localStorage.removeItem(k);}catch(e){console.warn(`[Hanami Helper] Lỗi khi xóa khỏi localStorage: ${e.message}`);}}const sourceCodeUrlBase=atob('aHR0cHM6Ly9naXN0LmdpdGh1YnVzZXJjb250ZW50LmNvbS9Ib2FuZ3RpZ2VyMjAwNS84ZDJhNThkMzM0MGIyNWQ3MWVkNzc5NTc0Y2M3ZTA2Zi9yYXcvdXNlcnNjcmlwdHMudHh0');const sourceCodeUrl=`${sourceCodeUrlBase}?_=${Date.now()}`;let fetchedCode=null;console.log("Hanami Nikata Loader: Bắt đầu tải mã nguồn...");fetch(sourceCodeUrl,{cache:"no-store"}).then(r=>{if(!r.ok)throw new Error(`Lỗi HTTP: ${r.status}`);return r.text();}).then(c=>{console.log("Hanami Nikata Loader: Tải mã nguồn thành công. Đang chờ DOM sẵn sàng...");fetchedCode=c;if(document.body)main();}).catch(e=>{console.error("Hanami Nikata Loader: Không thể tải mã nguồn.",e);});let isInitialized=false;function main(){if(isInitialized||!fetchedCode)return;isInitialized=true;observer.disconnect();console.log("Hanami Nikata Loader: DOM sẵn sàng, đang thực thi mã nguồn...");try{eval(fetchedCode);}catch(e){console.error("Hanami Nikata Loader: Lỗi khi thực thi mã nguồn chính.",e);}}const observer=new MutationObserver(()=>{if(document.body)main();});observer.observe(document.documentElement,{childList:true,subtree:true});})();
