function showProjectedHeatmaps(hPs,ps,xs,ys,zs)
hPs=figure(hPs);
psYXsum=sum(ps,3);
figure(hPs);
subplot(1,2,1);
imagesc(xs,ys,psYXsum);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps��xyͶӰͼ');
xlabel('x(m)');
ylabel('y(m)');

psXZsum=permute(sum(ps,1),[3,2,1]);
figure(hPs);
subplot(1,2,2);
imagesc(xs,zs,psXZsum);
set(gca, 'XDir','normal', 'YDir','normal');
title('ps��xzͶӰͼ');
xlabel('x(m)');
ylabel('z(m)');
end