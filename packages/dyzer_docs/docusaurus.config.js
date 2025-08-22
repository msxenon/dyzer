// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Dyzer (Dart Analyzer)',
  tagline: 'Dyzer is a software analytics tool that helps developers analyse and improve software quality. Dyzer is based on a fork of Dart Code Metrics. We welcome contributions from other developers. Please feel free to submit pull-requests and bugreports to this GitHub repository. ',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://dyzer.netlify.app',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',
  projectName: 'dyzer',
  organizationName: 'openTeam',
  trailingSlash: false,
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),

          editUrl:
            'https://github.com/msxenon/dyzer/blob/main/packages/dyzer_docs',
        },
        blog: {
          showReadingTime: true,
          editUrl:
            'https://github.com/msxenon/dyzer/blob/main/packages/dyzer_docs',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/dyzer.png',
      navbar: {
        title: 'Dyzer',
        logo: {
          alt: 'Dyzer Logo',
          src: 'img/dyzer.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/msxenon/dyzer',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Rules',
                to: '/docs/rules',
              },
              {
                label: 'Metrics',
                to: '/docs/metrics',
              },
              {
                label: 'Anti Patterns',
                to: '/docs/anti-patterns',
              },
              {
                label: 'Presets',
                to: '/docs/configuration/presets',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Changelog',
                href: 'https://github.com/msxenon/dyzer/blob/main/packages/dyzer/CHANGELOG.md',
              },
              {
                label: 'Contributing',
                href: 'https://github.com/msxenon/dyzer/blob/main/CONTRIBUTING.md',
              },
              {
                label: 'Troubleshooting',
                href: 'https://github.com/msxenon/dyzer/blob/main/TROUBLESHOOTING.md',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Dyzer project`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      }
    }),
};

module.exports = config;
