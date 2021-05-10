import Link from 'next/link'
import Image from 'next/image';
import Head from 'next/head';
import Layout from '../../components/layout'

export default function FirstPost() {
    return (
    <Layout>
        <Head>
            <title>First Post</title>
        </Head>
        <h1>First Post</h1>
        <h2>
        <Link href="/"><a>back to home</a></Link>
        </h2>
        <Image
        src="/images/profile.jpeg"
        width={144}
        height={144}
        alt='Samuel Nwokenkwo'
         />
        
    </Layout>
    )
  }