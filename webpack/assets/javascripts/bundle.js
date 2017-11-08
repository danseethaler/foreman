/* eslint-disable global-require */
/* eslint-disable import/no-webpack-loader-syntax */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/no-unresolved */
/* eslint-disable import/extensions */
import 'babel-polyfill';
import 'jquery-ujs';
import 'jquery.cookie';

import 'expose-loader?ipaddr!ipaddr.js';
import 'expose-loader?_!lodash';
import 'expose-loader?jstz!jstz';
import 'expose-loader?JsDiff!diff';
import 'expose-loader?$!expose-loader?jQuery!jquery';

import compute from './foreman_compute_resource';
import './bundle_flot';
import './bundle_multiselect';
import './bundle_select2';
import './bundle_datatables';

window.tfm = Object.assign(window.tfm || {}, {
  tools: require('./foreman_tools'),
  users: require('./foreman_users'),
  computeResource: compute,
  sshKeys: require('./foreman_ssh_keys'),
  trends: require('./foreman_trends'),
  hostgroups: require('./foreman_hostgroups'),
  hosts: require('./foreman_hosts'),
  httpProxies: require('./foreman_http_proxies'),
  toastNotifications: require('./foreman_toast_notifications'),
  numFields: require('./jquery.ui.custom_spinners'),
  reactMounter: require('./react_app/common/MountingService'),
  editor: require('./foreman_editor'),
  nav: require('./foreman_navigation'),
});
