'use strict';

const path = require('path');

const VueLoaderPlugin = require('vue-loader/lib/plugin');

module.exports = {
    mode: 'development',
    plugins: [
        new VueLoaderPlugin(),
    ],
    entry: [
        path.join(__dirname, 'web', 'src', 'app.js'),
    ],
    output: {
        filename: 'bundle.js',
        path: path.join(__dirname, 'web', 'dist'),
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
                query: {
                    presets: ['@babel/env'],
                },
            },
            {
                test: /\.vue$/,
                loader: 'vue-loader',
            },
            {
                test: /\.css$/,
                use: [
                    'vue-style-loader',
                    'css-loader',
                ],
            },
        ],
    },
    resolve: {
        alias: {
            src: path.join(__dirname, 'web', 'src'),
            components: path.join(__dirname, 'web', 'src', 'components'),
            'vue$': 'vue/dist/vue.esm.js',  // todo: remove once all templates are compiled at build time
        },
    },
};
